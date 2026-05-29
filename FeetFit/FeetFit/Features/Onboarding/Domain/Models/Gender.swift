//
//  Gender.swift
//  FeetFit
//
//  Created by 이채은 on 5/22/26.
//

import Foundation

enum Gender {
    case male
    case female
    
    var apiValue: String {
        switch self {
        case .male:
            return "MALE"
        case .female:
            return "FEMALE"
        }
    }
}
