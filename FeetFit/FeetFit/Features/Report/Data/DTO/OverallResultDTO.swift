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

    // 응답에서 빠질 수 있어 옵셔널로 둔다.
    let conditionLevel: String?
    let conditionComments: [String]?

    let balanceScore: Double
    let balanceComment: String
    let balanceScoreDiff: Double?

    let leftPressurePercent: Double
    let rightPressurePercent: Double
    let leftPressureImageUrl: String?
    let rightPressureImageUrl: String?

    let leftPlantarFootprintImageUrl: String?
    let rightPlantarFootprintImageUrl: String?
    let plantarFootprintAnalysisText: String

    let userFootSize: Int
    let measuredLeftFootSizeMm: Double?
    let measuredRightFootSizeMm: Double?
    let leftFootSizeDiff: Double?
    let rightFootSizeDiff: Double?
    let leftFootWidthMm: Double?
    let rightFootWidthMm: Double?

    // 응답에서 빠질 수 있어 옵셔널로 둔다.
    let beforeTemperatureCelsius: Double?
    let beforeHumidityPercent: Double?
    let afterTemperatureCelsius: Double?
    let afterHumidityPercent: Double?

    let avgTemperatureCelsius: Double
    let avgHumidityPercent: Double

    // 응답에서 빠질 수 있어 옵셔널로 둔다.
    let careTips: [String]?
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

    var temperatureValue: Double {
        avgTemperatureCelsius
    }

    var humidityValue: Double {
        avgHumidityPercent
    }

    // before/after 값이 없을 경우 평균값으로 대체해, 이전=이후=평균으로 표시(마커가 같은 위치에 겹침)한다.
    var beforeTemperatureValue: Double {
        beforeTemperatureCelsius ?? avgTemperatureCelsius
    }

    var afterTemperatureValue: Double {
        afterTemperatureCelsius ?? avgTemperatureCelsius
    }

    var beforeHumidityValue: Double {
        beforeHumidityPercent ?? avgHumidityPercent
    }

    var afterHumidityValue: Double {
        afterHumidityPercent ?? avgHumidityPercent
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

#if DEBUG
extension DailyFootAnalysisResultDTO {
    static let mock = DailyFootAnalysisResultDTO(
        id: 4,
        measurementSessionId: 34,
        conditionLevel: "ATTENTION_NEEDED",
        conditionComments: [
            "오른발에 압력이 조금 더 실려 있어요.",
            "양발 발볼 너비 차이가 있어 신발 선택 시 유의가 필요해요."
        ],
        balanceScore: 72,
        balanceComment: "자세 균형에 대한 내용입니다.",
        balanceScoreDiff: 0,
        leftPressurePercent: 46,
        rightPressurePercent: 54,
        leftPressureImageUrl: "https://project5-42-oregon-feetfit-s3.s3.us-west-2.amazonaws.com/pressure-left/7ac068ed-a203-4b95-a280-257a37ce3053.png",
        rightPressureImageUrl: "https://project5-42-oregon-feetfit-s3.s3.us-west-2.amazonaws.com/pressure-right/e245c3c1-930c-41c1-8423-e60268fe3f17.png",
        leftPlantarFootprintImageUrl: "https://project5-42-oregon-feetfit-s3.s3.us-west-2.amazonaws.com/plantar-footprint-left/c4a58376-a617-4850-80cd-357eeb815434.png",
        rightPlantarFootprintImageUrl: "https://project5-42-oregon-feetfit-s3.s3.us-west-2.amazonaws.com/plantar-footprint-right/f48ed2ab-a214-4229-a32a-0a9e2382b4b8.png",
        plantarFootprintAnalysisText: "왼발은 발바닥 전체가 고르게 접촉되어 단일 영역으로 분포되며, 오른발은 두 개 영역에 나눠 접촉하는 차이가 관찰됩니다.\n양쪽 발의 접촉 위치와 연속성 차이를 고려할 때 명확한 평발 또는 요족 형태 경향에 대한 근거는 부족합니다.",
        userFootSize: 240,
        measuredLeftFootSizeMm: 253,
        measuredRightFootSizeMm: 248,
        leftFootSizeDiff: 13,
        rightFootSizeDiff: 8,
        leftFootWidthMm: 85,
        rightFootWidthMm: 70,
        beforeTemperatureCelsius: 28,
        beforeHumidityPercent: 45,
        afterTemperatureCelsius: 34,
        afterHumidityPercent: 55,
        avgTemperatureCelsius: 31,
        avgHumidityPercent: 50,
        careTips: [
            "오른발 앞꿈치 스트레칭을 해주세요.",
            "신발은 착용 후 충분히 말려주세요.",
            "발볼이 좁은 신발은 피하는 것이 좋아요."
        ],
        typeText: "발의 아치가 낮아 발바닥이 넓게 닿는 편이에요. 오래 걷거나 서 있으면 피로가 커질 수 있어 아치를 잘 받쳐주는 신발이 더 편안할 수 있어요.",
        createdAt: "2026-07-07T17:58:13.086989",
        updatedAt: "2026-07-07T18:01:25.20295"
    )
}
#endif
