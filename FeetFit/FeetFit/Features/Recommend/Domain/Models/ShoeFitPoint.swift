//
//  ShoeFitPoint.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import Foundation
import SwiftUI

struct ShoeFitPoint: Identifiable, Codable {
    let id: Int
    let type: ShoeFitPointType
    let status: MainBoxStatus
}
