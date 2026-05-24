//
//  EnvironmentType.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

enum EnvironmentType {
    case temperature
    case humidity
    
    var title: String {
        switch self {
        case .temperature: return "온도"
        case .humidity: return "습도"
        }
    }
    
    var unit: String {
        switch self {
        case .temperature: return "℃"
        case .humidity: return "%"
        }
    }
    
    var color: Color {
        switch self {
        case .temperature: return .red01
        case .humidity: return .blue01
        }
    }
    
    var maxValue: Double {
        switch self {
        case .temperature: return 50
        case .humidity: return 100
        }
    }
}
