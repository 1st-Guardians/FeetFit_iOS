//
//  MeasurementSocketManager.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import Foundation

final class MeasurementSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?

    private let socketURL = URL(string: "ws://54.184.58.176/ws/measurements")!

    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: socketURL)

        webSocketTask?.resume()

        print("WebSocket 연결 시작")

        receiveMessage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendConnectFrame()
        }
    }

    private func sendConnectFrame() {
        let frame = """
        CONNECT
        accept-version:1.2
        host:54.184.58.176

        """
        + "\u{00}"

        send(frame)
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("WebSocket 수신:")
                    print(text)

                    self.handleSTOMPMessage(text)

                case .data(let data):
                    print("WebSocket Data 수신:", data)

                @unknown default:
                    break
                }

                self.receiveMessage()

            case .failure(let error):
                print("WebSocket 수신 실패:", error)
            }
        }
    }

    private func handleSTOMPMessage(_ text: String) {
        if text.hasPrefix("CONNECTED") {
            print("STOMP 연결 성공")
            
            // TODO: 사용자 Topic 구독

            return
        }

        if text.hasPrefix("MESSAGE") {
            let body = extractBody(from: text)
            print("STOMP 메시지 body:")
            print(body ?? "body 없음")
        }

        if text.hasPrefix("ERROR") {
            print("STOMP ERROR 수신:")
            print(text)
        }
    }

    private func extractBody(from message: String) -> String? {
        guard let range = message.range(of: "\n\n") else {
            return nil
        }

        return String(message[range.upperBound...])
            .replacingOccurrences(of: "\u{00}", with: "")
    }

    private func send(_ text: String) {
        webSocketTask?.send(.string(text)) { error in
            if let error {
                print("WebSocket 전송 실패:", error)
            } else {
                print("WebSocket 전송 성공")
            }
        }
    }

    func disconnect() {
        let frame = """
        DISCONNECT

        """
        + "\u{00}"

        send(frame)

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        print("WebSocket 연결 종료")
    }
}
