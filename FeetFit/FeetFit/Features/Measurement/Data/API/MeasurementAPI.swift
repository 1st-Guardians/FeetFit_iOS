//
//  MeasurementAPI.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation
import Moya

final class MeasurementAPI {
    static let shared = MeasurementAPI()
    
    private let provider = APIManager.shared.createProvider(
        for: MeasurementRouter.self,
        withAuth: true
    )
    
    private init() {}
    
    // 주간 측정 현황
    func fetchWeeklyStatus() async throws -> WeeklyStatus {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getWeeklyStatus) { result in
                switch result {
                case .success(let response):
                    print("Weekly Status statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<WeeklyStatusResultDTO>.self,
                            from: response.data
                        )

                        guard decoded.isSuccess else {
                            continuation.resume(
                                throwing: APIError.serverError(decoded.message)
                            )
                            return
                        }

                        guard let result = decoded.result else {
                            continuation.resume(
                                throwing: APIError.serverError("주간 상태 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result.toDomain)
                    } catch {
                        print("Weekly Status decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Weekly Status failure statusCode:", response.statusCode)

                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponse.self,
                            from: response.data
                        )

                        if response.statusCode == 401 {
                            continuation.resume(throwing: APIError.unauthorized)
                            return
                        }

                        continuation.resume(
                            throwing: APIError.serverError(
                                errorResponse?.message ?? "알 수 없는 오류가 발생했습니다."
                            )
                        )
                        return
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }

    // 측정 시작
    func postMeasurementSessions() async throws -> MeasurementSessionResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.postSessions) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<MeasurementSessionResultDTO>.self,
                            from: response.data
                        )
                        
                        guard let result = decoded.result else {
                            continuation.resume(throwing: APIError.unknown)
                            return
                        }
                        
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
