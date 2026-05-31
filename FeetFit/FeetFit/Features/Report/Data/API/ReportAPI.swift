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

    
    // 요약 리포트
    func fetchReportSummary() async throws -> ReportSummaryResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getSummary) { result in
                switch result {
                case .success(let response):
                    print("Report statusCode:", response.statusCode)

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
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }
    
    // 종합 결과 리포트
    func fetchDailyFootAnalysis(date: String) async throws -> DailyFootAnalysisResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getDailyFootAnalysis(date: date)) { result in
                switch result {
                case .success(let response):
                    print("Daily Analysis statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<DailyFootAnalysisResultDTO>.self,
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
                                throwing: APIError.serverError("일일 발 분석 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result)
                    } catch {
                        print("Daily Analysis decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Daily Analysis failure statusCode:", response.statusCode)

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
    
    // 무지외반 결과 리포트
    func fetchHalluxValgus(date: String) async throws -> HalluxValgusResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getHalluxValgus(date: date)) { result in
                switch result {
                case .success(let response):
                    print("Hallux Valgus statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<HalluxValgusResultDTO>.self,
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
                                throwing: APIError.serverError("무지외반 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result)
                    } catch {
                        print("Hallux Valgus decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Hallux Valgus failure statusCode:", response.statusCode)

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
    
    // 무좀 결과 리포트
    func fetchAthletesFoot(date: String) async throws -> AthletesFootResultDTO {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getAthletesFoot(date: date)) { result in
                switch result {
                case .success(let response):
                    print("Athletes Foot statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<AthletesFootResultDTO>.self,
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
                                throwing: APIError.serverError("무좀 분석 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result)
                    } catch {
                        print("Athletes Foot decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Athletes Foot failure statusCode:", response.statusCode)

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
    
    // 캘린더
    func fetchMeasuredDates(year: Int, month: Int) async throws -> [Date] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getMeasuredDates(year: year, month: month)) { result in
                switch result {
                case .success(let response):
                    print("Measured Dates statusCode:", response.statusCode)
                    
                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<MeasuredDatesResultDTO>.self,
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
                                throwing: APIError.serverError("측정 날짜 응답이 비어 있습니다.")
                            )
                            return
                        }
                        
                        let dates = result.measuredDates.compactMap {
                            Self.measuredDateFormatter.date(from: $0)
                        }
                        
                        continuation.resume(returning: dates)
                    } catch {
                        print("Measured Dates decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }
                    
                case .failure(let error):
                    if let response = error.response {
                        print("Measured Dates failure statusCode:", response.statusCode)
                        
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

    private static let measuredDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
