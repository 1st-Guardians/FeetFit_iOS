//
//  FootMeasurementViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation
import Moya

@Observable
final class FootMeasurementViewModel {
    private let socketManager = MeasurementSocketManager.shared
    private let myPageProvider = APIManager.shared.createProvider(
        for: MyPageRouter.self,
        withAuth: true
    )

    var isLoading = false
    var errorMessage: String?

    var measurementSessionId: Int?
    var measurementStatus: MeasurementStatus?
    var photoCaptureAttempt: Int?
    private(set) var isPhotoRecapture = false
    var isStatusUpdateInFlight = false

    var onMoveToProgress: (() -> Void)?
    var onMoveToFinish: (() -> Void)?

    // 사용자 topic을 세션 생성 전에 구독했는지 여부. connectDevice()마다 초기화된다.
    private var isUserTopicSubscribed = false
    // measurementSessionId가 확정되기 전(POST 응답 도착 전)에 온 메시지를 순서대로 보관해 둔다.
    private var pendingMessageBodies: [String] = []

    init() {
        bindSocketCallbacks()
    }

    private func bindSocketCallbacks() {
        socketManager.onConnected = { [weak self] in
            guard let self else { return }

            _Concurrency.Task { @MainActor in
                self.isLoading = false

                print("CONNECTED 수신 → Progress 화면으로 이동")
                self.onMoveToProgress?()
            }
        }

        socketManager.onMeasurementMessage = { [weak self] body in
            guard let self else { return }

            _Concurrency.Task { @MainActor in
                self.handleMeasurementMessage(body)
            }
        }

        socketManager.onError = { [weak self] error in
            _Concurrency.Task { @MainActor in
                guard let self, self.measurementStatus != .completed, self.measurementStatus != .failed else { return }
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.measurementStatus = .failed
            }
        }
    }

    // MARK: - 기기 연결

    @MainActor
    func resetMeasurementState() {
        isLoading = false
        errorMessage = nil
        measurementSessionId = nil
        measurementStatus = nil
        photoCaptureAttempt = nil
        isPhotoRecapture = false
        isStatusUpdateInFlight = false
        isUserTopicSubscribed = false
        pendingMessageBodies = []
    }

    @MainActor
    func connectDevice() {
        guard !isLoading else { return }

        resetMeasurementState()
        bindSocketCallbacks()
        isLoading = true

        socketManager.connect()
    }

    // MARK: - 사용자 topic 구독 (세션 생성 전)

    /// 측정 세션 생성(POST) 전에 사용자 topic을 먼저 구독해 둔다.
    /// 세션 생성 후에 구독하면 직후 전송되는 WAITING_FOR_PHOTO_ENVIRONMENT를 놓칠 수 있다.
    private func subscribeUserTopicIfNeeded() async {
        guard !isUserTopicSubscribed else { return }

        guard let userId = await fetchUserId() else {
            print("userId 조회 실패 → 사용자 topic 구독 불가")
            return
        }

        socketManager.subscribe(to: "/topic/users/\(userId)/measurements")
        isUserTopicSubscribed = true

        print("사용자 topic 구독 완료 (세션 생성 전): userId", userId)
    }

    // MARK: - 측정 세션 시작

    @MainActor
    func startMeasurementSessionIfNeeded() async {
        guard measurementSessionId == nil else {
            print("이미 측정 세션이 생성되어 있음")
            return
        }

        await startMeasurementSession()
    }

    @MainActor
    private func startMeasurementSession() async {
        do {
            // 사용자 topic 구독이 아직 안 끝났다면(예: onConnected 처리와 경합) 여기서 한 번 더 보장한다.
            await subscribeUserTopicIfNeeded()

            let result = try await MeasurementAPI.shared.postMeasurementSessions()

            self.measurementSessionId = result.id
            // POST 응답의 status를 최초 UI 상태로 즉시 반영한다.
            self.measurementStatus = result.status
            self.photoCaptureAttempt = result.photoCaptureAttempt

            socketManager.subscribe(to: "/topic/measurements/\(result.id)")

            print("측정 세션 생성 성공")
            print("session id:", result.id)
            print("초기 status:", result.status.rawValue)

            // 세션 확정 전에 사용자 topic으로 먼저 도착해 임시 보관해 둔 메시지들을
            // 이 세션에 해당하는 것만 순서대로 처리한다.
            flushPendingMessages()

        } catch {
            errorMessage = error.localizedDescription
            measurementStatus = .failed
            print("측정 세션 생성 실패:", error)
        }
    }

    /// 사용자 topic(/topic/users/{userId}/measurements) 구독을 위해 프로필에서 userId만 가져온다.
    private func fetchUserId() async -> Int? {
        await withCheckedContinuation { continuation in
            myPageProvider.request(.getProfile) { result in
                switch result {
                case .success(let response):
                    let decoded = try? JSONDecoder().decode(
                        BaseResponse<MyPageProfileResult>.self,
                        from: response.data
                    )
                    continuation.resume(returning: decoded?.result?.userId)

                case .failure(let error):
                    print("userId 조회 실패:", error)
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    // MARK: - 사용자 준비 완료 액션

    @MainActor
    func confirmPhotoEnvironmentReady() async {
        await patchStatus(.readyForPhotoEnvironment, from: .waitingForPhotoEnvironment)
    }

    @MainActor
    func confirmPressureReady() async {
        await patchStatus(.readyForPressure, from: .waitingForPressure)
    }

    @MainActor
    func confirmRecaptureReady() async {
        await patchStatus(.readyForRecapture, from: .waitingForRecapture)
    }

    @MainActor
    func confirmPressureRetryReady() async {
        await patchStatus(.readyForPressureRetry, from: .waitingForPressureRetry)
    }

    @MainActor
    private func patchStatus(_ status: MeasurementStatus, from expectedStatus: MeasurementStatus) async {
        guard measurementStatus == expectedStatus, !isStatusUpdateInFlight else { return }

        guard let measurementSessionId else {
            print("measurementSessionId가 없어 상태 변경 요청을 보낼 수 없음")
            return
        }

        isStatusUpdateInFlight = true
        errorMessage = nil

        do {
            let result = try await MeasurementAPI.shared.patchMeasurementSessionStatus(
                sessionId: measurementSessionId,
                status: status
            )

            print("측정 상태 PATCH 성공:", result.status.rawValue)
            // PATCH 응답이 늦게 도착해도 이미 수신한 소켓 상태를 덮어쓰지 않는다.
            if measurementStatus == expectedStatus {
                measurementStatus = result.status
                photoCaptureAttempt = result.photoCaptureAttempt ?? photoCaptureAttempt
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("측정 상태 PATCH 실패:", error)
        }

        isStatusUpdateInFlight = false
    }

    // MARK: - WebSocket 메시지 처리

    @MainActor
    private func handleMeasurementMessage(_ body: String) {
        // POST /api/measurement-sessions 응답으로 세션 ID가 확정되기 전에는
        // 어떤 세션의 메시지인지 판단할 수 없으므로 버리지 않고 순서대로 보관해 둔다.
        // 세션이 확정되면 flushPendingMessages()에서 해당 세션 메시지만 골라 처리한다.
        guard measurementSessionId != nil else {
            print("세션 ID 확정 전 메시지 → 임시 보관")
            pendingMessageBodies.append(body)
            return
        }

        processMeasurementMessage(body)
    }

    /// 세션 확정 전 임시 보관해 둔 메시지 중, 확정된 현재 세션에 해당하는 메시지만 순서대로 처리한다.
    /// (다른 세션의 메시지는 processMeasurementMessage 내부의 세션 ID 가드에서 걸러진다.)
    @MainActor
    private func flushPendingMessages() {
        guard !pendingMessageBodies.isEmpty else { return }

        let bodies = pendingMessageBodies
        pendingMessageBodies = []

        print("임시 보관된 메시지 재처리:", bodies.count, "개")

        for body in bodies {
            processMeasurementMessage(body)
        }
    }

    @MainActor
    private func processMeasurementMessage(_ body: String) {
        print("측정 메시지 raw body:")
        print(body)

        guard let data = body.data(using: .utf8) else {
            print("측정 메시지 Data 변환 실패")
            return
        }

        do {
            let message = try JSONDecoder().decode(
                MeasurementSocketMessageDTO.self,
                from: data
            )

            print("측정 메시지 파싱 성공")
            print("eventType:", message.eventType)
            print("sessionId:", message.measurementSessionId)
            print("status:", message.status.rawValue)
            print("statusMessage:", message.statusMessage ?? "nil")
            print("detail:", message.detail ?? "nil")
            print("photoCaptureAttempt:", message.photoCaptureAttempt?.description ?? "nil")
            print("remainingPhotoRecaptures:", message.remainingPhotoRecaptures?.description ?? "nil")
            print("pressureMeasurementAttempt:", message.pressureMeasurementAttempt?.description ?? "nil")
            print("remainingPressureRetries:", message.remainingPressureRetries?.description ?? "nil")
            print("shouldDisconnect:", message.shouldDisconnect)

            // 소켓 매니저가 싱글턴이라, 재시도 등으로 세션이 바뀐 뒤에도
            // 이전 세션의 지연 메시지가 새 세션 상태를 덮어쓰지 않도록 세션 ID를 확인한다.
            guard message.measurementSessionId == measurementSessionId else {
                print("현재 세션(\(measurementSessionId?.description ?? "nil"))과 다른 세션(\(message.measurementSessionId))의 메시지라 무시함")
                return
            }

            // 사용자·세션 topic에서 중복 전달된 종료 메시지는 한 번만 처리한다.
            guard measurementStatus != .completed, measurementStatus != .failed else { return }

            // UI는 eventType이 아니라 status를 기준으로 동작한다.
            measurementStatus = message.status
            if message.status == .waitingForRecapture || message.status == .readyForRecapture {
                isPhotoRecapture = true
            }
            photoCaptureAttempt = message.photoCaptureAttempt ?? photoCaptureAttempt
            print("measurementStatus 갱신됨:", measurementStatus?.rawValue ?? "nil")

            switch message.status {
            case .completed:
                print("COMPLETED 수신 → 결과 화면으로 이동")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

                onMoveToFinish?()

            case .failed:
                print("측정 실패 - failureReason:", message.failureReason?.rawValue ?? "nil")
                print("측정 실패 - failureMessage:", message.failureMessage ?? "nil")
                print("측정 실패 - failureDetail:", message.failureDetail ?? "nil")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

            case .waitingForPhotoEnvironment, .readyForPhotoEnvironment, .capturingPhotoEnvironment,
                 .waitingForRecapture, .readyForRecapture,
                 .waitingForPressure, .readyForPressure, .measuringPressure,
                 .waitingForPressureRetry, .readyForPressureRetry,
                 .analyzing:
                // 중간 상태는 measurementStatus 갱신 외에 별도 화면 전환이 없다.
                break
            }

        } catch {
            print("측정 메시지 JSON 디코딩 실패:", error)
            print("body:", body)
        }
    }

    // MARK: - 연결 종료

    func disconnect() {
        socketManager.disconnect()
    }
}
