//
//  NetworkProvider.swift
//  FeetFit
//

import Foundation
import Alamofire
import Moya

final class NetworkProvider<API: TargetType> {
    private let provider: MoyaProvider<API>

    init(withAuth: Bool = true) {
        let session = withAuth
            ? Session(interceptor: AuthInterceptor.shared)
            : Session()

        self.provider = MoyaProvider<API>(session: session)
    }

    func request<T: Decodable>(_ target: API, responseType: T.Type) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let filtered = try response.filterSuccessfulStatusCodes()
                        let decoded = try JSONDecoder().decode(T.self, from: filtered.data)
                        continuation.resume(returning: decoded)
                    } catch let moyaError as MoyaError {
                        continuation.resume(throwing: APIError.from(moyaError))
                    } catch {
                        continuation.resume(throwing: APIError.decodingError)
                    }
                case .failure(let error):
                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }

    func requestBase<T: Decodable>(_ target: API, dataType: T.Type) async throws -> T {
        let response: BaseResponse<T> = try await request(
            target,
            responseType: BaseResponse<T>.self
        )

        guard response.isSuccess else {
            throw APIError.serverError(response.message)
        }

        guard let data = response.result else {
            throw APIError.serverError(response.message)
        }

        return data
    }
    
    func requestBaseWithoutResult(_ target: API) async throws {
        let response: BaseResponse<EmptyResponse> = try await request(
            target,
            responseType: BaseResponse<EmptyResponse>.self
        )

        guard response.isSuccess else {
            throw APIError.serverError(response.message)
        }
    }
}
