//
//  ShoeFitPointType.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//
import Foundation

enum ShoeFitPointType: String, Codable {
    case width = "발볼"
    case heel = "뒤꿈치"
    case insole = "깔창"
    
    var iconName: String {
        switch self {
        case .width:
            return "checkmark"
        case .heel:
            return "exclamationmark.triangle.fill"
        case .insole:
            return "xmark"
        }
    }
}
