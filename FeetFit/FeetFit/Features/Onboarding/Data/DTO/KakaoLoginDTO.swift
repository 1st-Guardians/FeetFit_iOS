//
//  KakaoLoginDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation

struct KakaoLoginRequest: Encodable {
    let accessToken: String
}

struct KakaoLoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let grantType: String
    let expiresIn: Int64
    let requiresProfileSetup: Bool
}
