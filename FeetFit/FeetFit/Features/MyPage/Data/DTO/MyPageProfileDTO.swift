//
//  MyPageProfileDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation

struct MyPageProfileResult: Decodable {
    let userId: Int
    let nickname: String
    let age: Int
    let heightCm: Int
    let weightKg: Double
    let footSize: Int
    let gender: Gender
    let requiresProfileSetup: Bool
}
