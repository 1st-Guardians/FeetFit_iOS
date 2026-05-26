//
//  APIConfig.swift
//  FeetFit
//

import Foundation

enum APIConfig {
    static let baseURL = "https://api.feetfit.com"  // TODO: 실제 서버 URL로 교체

    enum Path {
        static let auth = "/api/auth"
        static let user = "/api/users"
        static let report = "/api/reports"
        static let shoes = "/api/shoes"
        static let device = "/api/devices"
        static let measurement = "/api/measurement-sessions"
    }
}
