//
//  Gender.swift
//  FeetFit
//
//  Created by 이채은 on 5/22/26.
//

import Foundation

enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
    
    var apiValue: String {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .male:
            return "남성"
        case .female:
            return "여성"
        }
    }
}
