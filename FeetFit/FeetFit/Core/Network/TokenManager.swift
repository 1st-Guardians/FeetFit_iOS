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
        get {
            KeychainManager.standard.loadString(for: accessTokenKey)
        }
        set {
            if let newValue {
                KeychainManager.standard.saveString(newValue, for: accessTokenKey)
            } else {
                KeychainManager.standard.delete(for: accessTokenKey)
            }
        }
    }

    var refreshToken: String? {
        get {
            KeychainManager.standard.loadString(for: refreshTokenKey)
        }
        set {
            if let newValue {
                KeychainManager.standard.saveString(newValue, for: refreshTokenKey)
            } else {
                KeychainManager.standard.delete(for: refreshTokenKey)
            }
        }
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
