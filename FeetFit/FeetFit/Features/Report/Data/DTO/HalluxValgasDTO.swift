//
//  HalluxValgasDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import CoreGraphics

struct HalluxValgusResultDTO: Decodable {
    let id: Int
    let measurementSessionId: Int

    let leftToeAngleDegree: Double
    let leftAnalysisText: String
    let leftImageUrl: String?

    let rightToeAngleDegree: Double
    let rightAnalysisText: String
    let rightImageUrl: String?

    let riskScore: Double
    let scoreAnalysisText: String

    let previousRiskScore: Double?
    let riskScoreDiff: Double?

    let createdAt: String
    let updatedAt: String
}

extension HalluxValgusResultDTO {
    var riskScoreInt: Int {
        Int(riskScore.rounded())
    }

    var riskScoreDiffInt: Int? {
        riskScoreDiff.map { Int($0.rounded()) }
    }

    var leftToeAngleCGFloat: CGFloat {
        CGFloat(leftToeAngleDegree)
    }

    var rightToeAngleCGFloat: CGFloat {
        CGFloat(rightToeAngleDegree)
    }
}
