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

    var measurementStatusText = "발 측정 준비 중..."
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
                self?.measurementStatusText = "WebSocket 연결이 끊겼어요"
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
        isMeasurementCompleted = false
        measurementStatusText = "기기와 연결 중이에요"

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
            measurementStatusText = "측정 세션 생성 중..."

            let result = try await MeasurementAPI.shared.postMeasurementSessions()

            self.session = result

            print("측정 세션 생성 성공")
            print("session id:", result.id)
            print("topic:", result.webSocketTopic)

            socketManager.subscribe(
                to: result.webSocketTopic,
                sessionId: result.id
            )

            measurementStatusText = "발 측정 중..."

        } catch {
            errorMessage = error.localizedDescription
            measurementStatusText = "측정 시작 실패"
            print("측정 세션 생성 실패:", error)
        }
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
            print("status:", message.status)
            print("shouldDisconnect:", message.shouldDisconnect)

            switch message.eventType {
            case "MEASUREMENT_STARTED":
                measurementStatusText = "발 측정 중..."

            case "MEASUREMENT_COMPLETED":
                measurementStatusText = "측정 완료!"
                isMeasurementCompleted = true

                print("MEASUREMENT_COMPLETED 수신 → 측정 완료 화면으로 이동")

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

                onMoveToFinish?()

            case "MEASUREMENT_FAILED":
                measurementStatusText = "측정 실패"
                errorMessage = "측정에 실패했습니다."

                if message.shouldDisconnect {
                    socketManager.disconnect()
                }

            default:
                print("알 수 없는 eventType:", message.eventType)
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
