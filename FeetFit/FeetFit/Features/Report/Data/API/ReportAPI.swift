//
//  ReportAPI.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import Moya

final class ReportAPI {
    static let shared = ReportAPI()

    private let provider = APIManager.shared.createProvider(
        for: ReportRouter.self,
        withAuth: true
    )

    private init() {}

    func fetchReportSummary() async throws -> ReportSummaryResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSummary) { result in
                switch result {
                case .success(let response):
                    print("Report statusCode:", response.statusCode)
                    print("Report response:", String(data: response.data, encoding: .utf8) ?? "")

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<ReportSummaryResultDTO>.self,
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
                                throwing: APIError.serverError("리포트 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result)
                    } catch {
                        print("Report decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Report failure statusCode:", response.statusCode)
                        print("Report failure response:", String(data: response.data, encoding: .utf8) ?? "")
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }
}
