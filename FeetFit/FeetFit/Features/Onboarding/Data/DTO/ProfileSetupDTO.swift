//
//  ProfileSetupDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation

struct ProfileSetupRequest: Encodable {
    let nickname: String
    let age: Int
    let heightCm: Double
    let weightKg: Double
    let footSize: Int
    let gender: String
    let termsAgreed: Bool
}

struct ProfileSetupResponse: Decodable {
    let userId: Int
    let nickname: String
    let age: Int
    let heightCm: Double
    let weightKg: Double
    let footSize: Int
    let gender: String
    let requiresProfileSetup: Bool
}
