//
//  OverallResultDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

//
//  DailyFootAnalysisDTO.swift
//  FeetFit
//

import Foundation

struct DailyFootAnalysisResultDTO: Decodable {
    let id: Int
    let measurementSessionId: Int

    let conditionLevel: String
    let conditionComments: [String]

    let balanceScore: Double
    let balanceComment: String
    let balanceScoreDiff: Double?

    let leftPressurePercent: Double
    let rightPressurePercent: Double
    let leftPressureImageUrl: String?
    let rightPressureImageUrl: String?

    let userFootSize: Int
    let measuredLeftFootSizeMm: Double?
    let measuredRightFootSizeMm: Double?
    let leftFootSizeDiff: Double?
    let rightFootSizeDiff: Double?
    let leftFootWidthMm: Double?
    let rightFootWidthMm: Double?

    let footOdourPpm: Double
    let footOdourComment: String

    let avgTemperatureCelsius: Double
    let avgHumidityPercent: Double

    let careTips: [String]
    let typeText: String

    let createdAt: String
    let updatedAt: String
}

extension DailyFootAnalysisResultDTO {
    var conditionStatus: MainBoxStatus {
        switch conditionLevel {
        case "VERY_GOOD":
            return .good
        case "ATTENTION_NEEDED":
            return .warn
        case "NEED_IMPROVEMENT":
            return .bad
        default:
            return .warn
        }
    }

    var balanceScoreInt: Int {
        Int(balanceScore.rounded())
    }

    var balanceScoreDiffInt: Int? {
        balanceScoreDiff.map { Int($0.rounded()) }
    }

    var leftPressureInt: Int {
        Int(leftPressurePercent.rounded())
    }

    var rightPressureInt: Int {
        Int(rightPressurePercent.rounded())
    }

    var footOdourCGFloat: CGFloat {
        CGFloat(footOdourPpm)
    }

    var temperatureValue: Double {
        avgTemperatureCelsius
    }

    var humidityValue: Double {
        avgHumidityPercent
    }

    var footSizeRows: [FootSizeRow] {
        [
            FootSizeRow(
                title: "입력 사이즈",
                left: "\(userFootSize)mm",
                leftDiff: nil,
                right: "\(userFootSize)mm",
                rightDiff: nil
            ),
            FootSizeRow(
                title: "측정 사이즈",
                left: formatMm(measuredLeftFootSizeMm),
                leftDiff: formatDiff(leftFootSizeDiff),
                right: formatMm(measuredRightFootSizeMm),
                rightDiff: formatDiff(rightFootSizeDiff)
            ),
            FootSizeRow(
                title: "발볼 너비",
                left: formatMm(leftFootWidthMm),
                leftDiff: nil,
                right: formatMm(rightFootWidthMm),
                rightDiff: nil
            )
        ]
    }

    private func formatMm(_ value: Double?) -> String {
        guard let value else { return "-" }
        return "\(Int(value.rounded()))mm"
    }

    private func formatDiff(_ value: Double?) -> String? {
        guard let value else { return nil }

        let intValue = Int(value.rounded())

        if intValue > 0 {
            return "+\(intValue)"
        } else {
            return "\(intValue)"
        }
    }
}
