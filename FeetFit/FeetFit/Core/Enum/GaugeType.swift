//
//  GaugeType.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

enum GaugeType {
    case greenToRed
    case redToGreen
    
    var colors: [Color] {
        switch self {
        case .greenToRed:
            return [.green01, .yellow01, .red01]
        case .redToGreen:
            return [.red01, .yellow01, .green01]
        }
    }
}
