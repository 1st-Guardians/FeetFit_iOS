//
//  UserInfo.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import Foundation

struct UserInfo {
    var nickname: String = ""
    var age: String = ""
    var weight: String = ""
    var height: String = ""
    var footSize: String = ""
    var gender: Gender? = nil
}

extension UserInfo {
    var isOnboardingFilled: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !height.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !footSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        gender != nil
    }
}
