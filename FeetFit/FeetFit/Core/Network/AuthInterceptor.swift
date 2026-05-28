//
//  AuthInterceptor.swift
//  FeetFit
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    private init() {}

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            request.retryCount == 0,
            let refreshToken = TokenManager.shared.refreshToken
        else {
            completion(.doNotRetry)
            return
        }

        refreshAccessToken(refreshToken: refreshToken) { result in
            switch result {
            case .success(let newToken):
                TokenManager.shared.accessToken = newToken
                completion(.retry)
            case .failure:
                TokenManager.shared.clear()
                completion(.doNotRetry)
            }
        }
    }

    private func refreshAccessToken(
        refreshToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // TODO: 실제 토큰 갱신 API 연동
        // AF.request(...)
        completion(.failure(APIError.unauthorized))
    }
}
