//
//  APIError.swift
//  FeetFit
//

import Foundation
import Moya

enum APIError: Error, LocalizedError {
    case networkError(MoyaError)
    case statusCode(Int)
    case decodingError
    case unauthorized
    case serverError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error): return error.localizedDescription
        case .statusCode(let code): return "서버 오류: \(code)"
        case .decodingError: return "데이터 파싱 오류"
        case .unauthorized: return "인증이 필요합니다"
        case .serverError(let message): return message
        case .unknown: return "알 수 없는 오류"
        }
    }

    static func from(_ moyaError: MoyaError) -> APIError {
        switch moyaError {
        case .statusCode(let response):
            if response.statusCode == 401 { return .unauthorized }
            return .statusCode(response.statusCode)
        default:
            return .networkError(moyaError)
        }
    }
}
