//
//  APIConfig.swift
//  FeetFit
//

import Foundation

enum APIConfig {
    static let baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              !url.isEmpty else {
            fatalError("API_BASE_URL이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig를 확인하세요.")
        }
        return url
    }()

    enum Path {
        static let auth = "/api/auth"
        static let user = "/api/users"
        static let report = "/api/reports"
        static let shoes = "/api/shoes"
        static let device = "/api/devices"
        static let measurement = "/api/measurement-sessions"
    }
}
