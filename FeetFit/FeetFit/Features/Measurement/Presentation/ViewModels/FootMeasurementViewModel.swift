//
//  FootMeasurementViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation

@Observable
final class FootMeasurementViewModel {
    private let socketManager = MeasurementSocketManager.shared

    var isLoading = false
    var errorMessage: String?
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

            Task { @MainActor in
                self.isLoading = false
                print("CONNECTED 수신 → Progress 화면으로 이동")
                self.onMoveToProgress?()
            }
        }

        socketManager.onMeasurementMessage = { [weak self] body in
            guard let self else { return }

            Task { @MainActor in
                self.handleMeasurementMessage(body)
            }
        }

        socketManager.onError = { [weak self] error in
            Task { @MainActor in
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

        } catch {
            errorMessage = error.localizedDescription
            measurementStatusText = "측정 시작에\n실패했어요"
            print("측정 세션 생성 실패:", error)
        }
    }

    // MARK: - 사용자 준비 완료 액션

    @MainActor
    func confirmPhotoReady() async {
        await patchStatus(.readyForPhoto)
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
                // 표시 우선순위: 백엔드가 준 사용자용 문구 > 실패 사유별 로컬 폴백 문구 > statusMessage > 기본 문구
                errorMessage = message.failureMessage
                    ?? message.failureReason?.fallbackMessage
                    ?? message.statusMessage
                    ?? MeasurementStatus.failed.guideMessage

                print("측정 실패 - failureReason:", message.failureReason?.rawValue ?? "nil")
                print("측정 실패 - failureDetail:", message.failureDetail ?? "nil")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

            case .waitingForPhoto, .readyForPhoto, .capturingPhoto,
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
}
