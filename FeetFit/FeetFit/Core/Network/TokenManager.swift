//
//  TokenManager.swift
//  FeetFit
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessTokenKey) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshTokenKey) }
    }

    func save(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clear() {
        accessToken = nil
        refreshToken = nil
    }

    var isLoggedIn: Bool {
        accessToken != nil
    }
}
