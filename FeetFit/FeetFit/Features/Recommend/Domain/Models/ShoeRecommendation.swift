//
//  ShoeRecommendation.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import Foundation

struct ShoeRecommendation: Codable {
    let userName: String
    let footDescription: String
    let shoes: [ShoeInfo]
}
