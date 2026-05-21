//
//  OnboardingUserInfo.swift
//  FeetFit
//
//  Created by 이채은 on 5/22/26.
//

import Foundation

struct OnboardingUserInfo {
    var nickname: String = ""
    var age: String = ""
    var weight: String = ""
    var height: String = ""
    var footSize: String = ""
    var gender: Gender? = nil
    
    var isFilled: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !height.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !weight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !footSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        gender != nil
    }
}
