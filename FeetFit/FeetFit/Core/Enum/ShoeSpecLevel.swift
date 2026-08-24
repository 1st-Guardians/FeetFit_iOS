//
//  ShoeSpecLevel.swift
//  FeetFit
//

import Foundation

enum ShoeSpecLevel: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"

    var title: String {
        switch self {
        case .low: return "낮음"
        case .medium: return "중간"
        case .high: return "높음"
        }
    }

    var normalizedValue: Double {
        switch self {
        case .low: return 1.0 / 3.0
        case .medium: return 2.0 / 3.0
        case .high: return 1.0
        }
    }
}
