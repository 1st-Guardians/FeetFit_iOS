//
//  AthletesFootDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import CoreGraphics

struct AthletesFootResultDTO: Decodable {
    let id: Int
    let measurementSessionId: Int

    let fungalSuspicionSafetyScore: Double
    let skinReactionSafetyScore: Double
    let totalScore: Double

    let previousTotalScore: Double?
    let totalScoreDiff: Double?

    let fungalSuspicionSafetyDescription: String
    let skinReactionSafetyDescription: String
    let totalScoreDescription: String

    let suspiciousAreaMapImageUrl: String?
    let originalFootImageUrl: String?

    let recordedAt: String
    let createdAt: String
    let updatedAt: String
}

extension AthletesFootResultDTO {
    var totalScoreInt: Int {
        Int(totalScore.rounded())
    }

    var totalScoreDiffInt: Int? {
        totalScoreDiff.map { Int($0.rounded()) }
    }

    var fungalScoreCGFloat: CGFloat {
        CGFloat(fungalSuspicionSafetyScore)
    }

    var skinReactionScoreCGFloat: CGFloat {
        CGFloat(skinReactionSafetyScore)
    }

    var scoreFormulaText: String {
        let calculatedScore = fungalSuspicionSafetyScore * 0.7 + skinReactionSafetyScore * 0.3

        return """
        무좀 의심 영역 70% + 피부 반응 영역 30%으로 계산됩니다.
        \(formatScore(fungalSuspicionSafetyScore)) × 0.7 + \(formatScore(skinReactionSafetyScore)) × 0.3 = \(formatScore(calculatedScore))점으로 계산되었습니다.
        """
    }

    func imageUrl(for type: AthleteImageType) -> String? {
        switch type {
        case .suspiciousMap:
            return suspiciousAreaMapImageUrl
        case .original:
            return originalFootImageUrl
        }
    }

    private func formatScore(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}
