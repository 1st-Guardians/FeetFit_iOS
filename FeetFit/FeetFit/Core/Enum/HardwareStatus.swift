//
//  HardwareStatus.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

enum HardwareStatus {
    case connected
    case unconnected
    
    var status: String {
        switch self {
        case .connected: return "연결됨"
        case .unconnected: return "연결 안 됨"
        }
    }
    
    var color: Color {
        switch self {
        case .connected: return .green01
        case .unconnected: return .red01
        }
    }
}
