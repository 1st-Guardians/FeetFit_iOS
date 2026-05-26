//
//  MainBoxStatus.swift
//  FeetFit
//
//  Created by 김미주 on 5/19/26.
//

import SwiftUI

enum MainBoxStatus: Codable {
    case good
    case warn
    case bad
    case none
    
    var title: String {
        switch self {
        case .good: return "매우 양호"
        case .warn: return "관심 필요"
        case .bad: return "개선 필요"
        case .none: return ""
        }
    }
    
    var color: Color {
        switch self {
        case .good: return .green01
        case .warn: return .yellow01
        case .bad: return .red01
        case .none: return .clear
        }
    }
}
