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
