//
//  ShoeFitAnalysis.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import Foundation

struct ShoeFitAnalysis: Identifiable, Codable {
    let id: Int
    let title: String
    let status: MainBoxStatus
    let reviewQuotes: [String]
    let description: String
}
