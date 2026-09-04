//
//  MeasurementSocketManager.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import Foundation

final class MeasurementSocketManager: NSObject, URLSessionWebSocketDelegate {
    static let shared = MeasurementSocketManager()

    private var webSocketTask: URLSessionWebSocketTask?

    private lazy var session = URLSession(
        configuration: .default,
        delegate: self,
        delegateQueue: nil
    )

    private var isConnected = false
    private var subscribedTopic: String?
    private var isManuallyDisconnected = false
    private var pingTimer: Timer?

    var onConnected: (() -> Void)?
    var onMeasurementMessage: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    private override init() {
        super.init()
    }

    // MARK: - Connect

    func connect() {
        guard let url = URL(string: APIConfig.socketURL) else {
            print("WebSocket URL 생성 실패")
            return
        }

        if isConnected {
            print("이미 WebSocket 연결됨")

            DispatchQueue.main.async {
                self.onConnected?()
            }

            return
        }

        isManuallyDisconnected = false

        print("WebSocket 연결 URL:", url.absoluteString)

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
    }

    // MARK: - STOMP CONNECT

    private func sendConnectFrame() {
        var frame = ""
        frame += "CONNECT\n"
        frame += "accept-version:1.2\n"
        frame += "\n"
        frame += "\u{00}"

        send(frame)
    }

    // MARK: - STOMP SUBSCRIBE with RECEIPT

    // 세션 topic과 사용자 topic을 동시에 구독할 수 있어, subscribeId는 topic마다 달라야 한다.
    // (sessionId만으로 만들면 같은 세션에 대한 두 topic이 id가 겹쳐 STOMP 구독이 깨진다.)
    func subscribe(to topic: String, sessionId: Int? = nil) {
        let subscribeId = "sub-measurement-\(abs(topic.hashValue))"

        var frame = ""
        frame += "SUBSCRIBE\n"
        frame += "id:\(subscribeId)\n"
        frame += "destination:\(topic)\n"
        frame += "\n"
        frame += "\u{00}"

        subscribedTopic = topic
        send(frame)

        print("STOMP 구독 요청:", topic)
    }

    // MARK: - Send

    private func send(_ text: String) {
        let printableFrame = text
            .replacingOccurrences(of: "\u{00}", with: "^@")

        print("===== STOMP 전송 frame =====")
        print(printableFrame)
        print("==========================")

        webSocketTask?.send(.string(text)) { error in
            if let error {
                print("WebSocket 전송 실패:", error)
            } else {
                if text.hasPrefix("CONNECT") {
                    print("STOMP CONNECT 전송 성공")
                } else if text.hasPrefix("SUBSCRIBE") {
                    print("STOMP SUBSCRIBE 전송 성공")
                } else if text.hasPrefix("DISCONNECT") {
                    print("STOMP DISCONNECT 전송 성공")
                } else {
                    print("WebSocket 전송 성공")
                }
            }
        }
    }

    // MARK: - Receive

    private func receive() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleStompFrame(text)

                case .data(let data):
                    print("WebSocket data 수신:", data)

                @unknown default:
                    print("알 수 없는 WebSocket 메시지")
                }

                self.receive()

            case .failure(let error):
                self.isConnected = false
                self.stopPing()

                if self.isManuallyDisconnected {
                    print("WebSocket 수신 종료: 직접 연결 종료")
                    return
                }

                print("WebSocket 수신 실패:", error)
                self.onError?(error)
            }
        }
    }

    // MARK: - Handle STOMP Frame

    private func handleStompFrame(_ text: String) {
        print("STOMP 수신:")
        print(text)

        // STOMP 프레임은 NUL(\u{00})로 구분된다. 하트비트(개행 하나)가 다음 MESSAGE 프레임과
        // 한 WebSocket 텍스트로 합쳐져 오면 앞에 개행이 붙어 hasPrefix("MESSAGE")가 실패하고
        // 아무 처리도 안 된 채 조용히 무시되므로, NUL 기준으로 프레임을 분리해 각각 처리한다.
        let frames = text
            .components(separatedBy: "\u{00}")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if frames.count > 1 {
            print("한 번에 여러 STOMP 프레임 수신:", frames.count, "개")
        }

        for frame in frames {
            handleSingleStompFrame(frame)
        }
    }

    private func handleSingleStompFrame(_ text: String) {
        if text.hasPrefix("CONNECTED") {
            isConnected = true
            print("STOMP 연결 완료")

            DispatchQueue.main.async {
                self.onConnected?()
            }

            return
        }

        if text.hasPrefix("RECEIPT") {
            print("STOMP 구독 RECEIPT 수신:")
            print(text)
            return
        }

        if text.hasPrefix("MESSAGE") {
            let body = extractBody(from: text)

            print("측정 메시지 body:")
            print(body)

            DispatchQueue.main.async {
                self.onMeasurementMessage?(body)
            }

            return
        }

        if text.hasPrefix("ERROR") {
            print("STOMP ERROR 수신:")
            print(text)
            return
        }
    }

    private func extractBody(from frame: String) -> String {
        let normalizedFrame = frame.replacingOccurrences(of: "\r\n", with: "\n")
        let parts = normalizedFrame.components(separatedBy: "\n\n")

        guard parts.count >= 2 else {
            return normalizedFrame
                .replacingOccurrences(of: "\u{00}", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return parts[1]
            .replacingOccurrences(of: "\u{00}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Ping

    private func startPing() {
        stopPing()

        DispatchQueue.main.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                self?.sendPing()
            }
        }
    }

    private func stopPing() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func sendPing() {
        webSocketTask?.sendPing { error in
            if let error {
                print("WebSocket ping 실패:", error)
            } else {
                print("WebSocket ping 성공")
            }
        }
    }

    // MARK: - Disconnect

    func disconnect() {
        isManuallyDisconnected = true
        stopPing()

        let frame =
        """
        DISCONNECT

        \u{00}
        """

        send(frame)

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        subscribedTopic = nil

        print("WebSocket 연결 종료")
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        print("URLSession WebSocket didOpen")

        isManuallyDisconnected = false

        receive()
        sendConnectFrame()
        startPing()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let reasonText = reason.flatMap {
            String(data: $0, encoding: .utf8)
        } ?? "nil"

        isConnected = false
        stopPing()

        print("URLSession WebSocket didClose")
        print("closeCode:", closeCode.rawValue)
        print("reason:", reasonText)
    }
}
