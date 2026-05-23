//
//  GaugeType.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

enum GaugeType {
    case smell
    case halluxValgus
    case athletesFoot
    
    var colors: [Color] {
        switch self {
        case .smell:
            return [.green01, .yellow01, .red01]
        case .halluxValgus:
            return [.green01, .yellow01, .red01]
        case .athletesFoot:
            return [.red01, .yellow01, .green01]
        }
    }
    
    var maxValue: Double {
        switch self {
        case .smell:
            return 5.0
        case .halluxValgus:
            return 40
        case .athletesFoot:
            return 100
        }
    }
    
    var unit: String {
        switch self {
        case .smell:
            return "ppm"
        case .halluxValgus:
            return "º"
        case .athletesFoot:
            return "점"
        }
    }
    
    var unitFont: Font.PretendardStyle {
        switch self {
        case .smell, .athletesFoot:
            return .SectionTitle
        case .halluxValgus:
            return .ScoreText
        }
    }
    
    var alignment: VerticalAlignment {
        switch self {
        case .smell, .athletesFoot:
            return .bottom
        case .halluxValgus:
            return .top
        }
    }
}
