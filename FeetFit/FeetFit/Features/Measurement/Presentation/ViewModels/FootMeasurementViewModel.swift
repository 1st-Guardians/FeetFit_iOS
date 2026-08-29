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
    /// 실패 상세 사유. failureMessage(제목)와 별개로 상세 설명 영역에 보여준다.
    var errorDetail: String?
    var session: MeasurementSessionResultDTO?

    var measurementSessionId: Int?
    var measurementStatus: MeasurementStatus?
    var isStatusUpdateInFlight = false

    var measurementStatusText = "발 측정\n준비 중..."
    var isMeasurementCompleted = false

    var onMoveToProgress: (() -> Void)?
    var onMoveToFinish: (() -> Void)?

    init() {
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
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                self?.measurementStatusText = "WebSocket 연결이\n끊겼어요"
            }
        }
    }

    // MARK: - 기기 연결

    @MainActor
    func connectDevice() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        errorDetail = nil
        session = nil
        measurementSessionId = nil
        measurementStatus = nil
        isMeasurementCompleted = false
        measurementStatusText = "기기와\n연결 중이에요"

        socketManager.connect()
    }

    // MARK: - 측정 세션 시작

    @MainActor
    func startMeasurementSessionIfNeeded() async {
        guard session == nil else {
            print("이미 측정 세션이 생성되어 있음")
            return
        }

        await startMeasurementSession()
    }

    @MainActor
    private func startMeasurementSession() async {
        do {
            measurementStatusText = "측정 세션\n생성 중..."

            // 세션 topic 구독을 지연시키지 않도록, userId 조회는 세션 생성과 병렬로 진행한다.
            async let userIdTask = fetchUserId()

            let result = try await MeasurementAPI.shared.postMeasurementSessions()

            self.session = result
            self.measurementSessionId = result.id
            // POST 응답의 status를 최초 UI 상태로 즉시 반영한다.
            // 서버가 세션 생성 직후 WebSocket으로 상태를 발행할 수 있어,
            // SUBSCRIBE 전에 온 최초 메시지를 놓치더라도 화면은 이미 올바른 상태를 보여준다.
            self.measurementStatus = result.status

            print("측정 세션 생성 성공")
            print("session id:", result.id)
            print("topic:", result.webSocketTopic)
            print("초기 status:", result.status.rawValue)

            socketManager.subscribe(
                to: result.webSocketTopic,
                sessionId: result.id
            )

            // 세션 topic 메시지가 누락되는 경우를 대비해, 서버가 함께 발행하는
            // 사용자 topic도 이중으로 구독해 둔다 (동일 상태 메시지가 두 topic으로 온다).
            if let userId = await userIdTask {
                socketManager.subscribe(
                    to: "/topic/users/\(userId)/measurements",
                    sessionId: result.id
                )
                print("사용자 topic 구독 완료: userId", userId)
            } else {
                print("userId 조회 실패 → 사용자 topic 구독 생략")
            }

        } catch {
            errorMessage = error.localizedDescription
            measurementStatusText = "측정 시작에\n실패했어요"
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
    func confirmPhotoReady() async {
        await patchStatus(.readyForPhoto)
    }

    @MainActor
    func confirmEnvironmentReady() async {
        await patchStatus(.readyForEnvironment)
    }

    @MainActor
    func confirmPressureReady() async {
        await patchStatus(.readyForPressure)
    }

    @MainActor
    private func patchStatus(_ status: MeasurementStatus) async {
        guard !isStatusUpdateInFlight else { return }

        guard let measurementSessionId else {
            print("measurementSessionId가 없어 상태 변경 요청을 보낼 수 없음")
            return
        }

        isStatusUpdateInFlight = true
        errorMessage = nil
        errorDetail = nil

        do {
            let result = try await MeasurementAPI.shared.patchMeasurementSessionStatus(
                sessionId: measurementSessionId,
                status: status
            )

            print("측정 상태 PATCH 성공:", result.status.rawValue)

            // source of truth는 이후 도착하는 WebSocket 상태 메시지이지만,
            // 버튼을 누른 직후 화면이 즉시 반응하도록 임시로 반영해 둔다.
            self.measurementStatus = result.status

        } catch {
            errorMessage = error.localizedDescription
            print("측정 상태 PATCH 실패:", error)
        }

        isStatusUpdateInFlight = false
    }

    // MARK: - WebSocket 메시지 처리

    @MainActor
    private func handleMeasurementMessage(_ body: String) {
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
            print("shouldDisconnect:", message.shouldDisconnect)

            // 소켓 매니저가 싱글턴이라, 재시도 등으로 세션이 바뀐 뒤에도
            // 이전 세션의 지연 메시지가 새 세션 상태를 덮어쓰지 않도록 세션 ID를 확인한다.
            guard message.measurementSessionId == measurementSessionId else {
                print("현재 세션(\(measurementSessionId?.description ?? "nil"))과 다른 세션(\(message.measurementSessionId))의 메시지라 무시함")
                return
            }

            // UI는 eventType이 아니라 status를 기준으로 동작한다.
            measurementStatus = message.status

            switch message.status {
            case .completed:
                isMeasurementCompleted = true

                print("COMPLETED 수신 → 측정 완료 화면으로 이동")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

                onMoveToFinish?()

            case .failed:
                // 제목: 백엔드가 준 사용자용 문구 > 실패 사유별 로컬 폴백 문구 > statusMessage > 기본 문구
                // 상세: failureDetail을 상세 원인으로 보여준다 (0825 스펙 추가). 오류코드 표기는 사용자에게 노출하지 않는다.
                let title = message.failureMessage
                    ?? message.failureReason?.fallbackMessage
                    ?? message.statusMessage
                    ?? MeasurementStatus.failed.guideMessage
                errorMessage = addLineBreakIfNeeded(title)
                errorDetail = message.failureDetail.map(removingErrorCode)

                print("측정 실패 - failureReason:", message.failureReason?.rawValue ?? "nil")
                print("측정 실패 - failureDetail:", message.failureDetail ?? "nil")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

            case .waitingForPhoto, .readyForPhoto, .capturingPhoto,
                 .waitingForEnvironment, .readyForEnvironment, .measuringEnvironment,
                 .waitingForPressure, .readyForPressure, .measuringPressure,
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

    // MARK: - 문구 가공

    /// 백엔드가 한 줄로 보내는 failureMessage도 앱 전반의 2줄 안내 문구 배치와 맞도록,
    /// 이미 줄바꿈이 없으면 첫 문장 뒤에서 한 번 끊어준다.
    private func addLineBreakIfNeeded(_ text: String) -> String {
        guard !text.contains("\n") else { return text }
        guard let range = text.range(of: ". ") else { return text }
        return text.replacingCharacters(in: range, with: ".\n")
    }

    /// failureDetail에 붙어 오는 "(오류코드: ~)" 같은 표기는 사용자에게 노출하지 않는다.
    private func removingErrorCode(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"\s*\(오류코드[^)]*\)"#,
            with: "",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
