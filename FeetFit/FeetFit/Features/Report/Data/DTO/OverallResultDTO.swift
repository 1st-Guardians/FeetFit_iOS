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
    let id: Int?
    let measurementSessionId: Int?

    // 응답에서 빠질 수 있어 옵셔널로 둔다.
    let conditionLevel: String?
    let conditionComments: [String]?

    let balanceScore: Double?
    let balanceComment: String?
    let balanceScoreDiff: Double?

    let leftPressurePercent: Double?
    let rightPressurePercent: Double?
    let leftPressureImageUrl: String?
    let rightPressureImageUrl: String?

    let leftPlantarFootprintImageUrl: String?
    let rightPlantarFootprintImageUrl: String?
    let plantarFootprintAnalysisText: String?

    let userFootSize: Int?
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

    let avgTemperatureCelsius: Double?
    let avgHumidityPercent: Double?

    // 응답에서 빠질 수 있어 옵셔널로 둔다.
    let careTips: [String]?
    let typeText: String?

    let createdAt: String?
    let updatedAt: String?
}

extension DailyFootAnalysisResultDTO {
    var hasRequiredOverallDisplayData: Bool {
        balanceScore != nil
            && balanceComment != nil
            && leftPressurePercent != nil
            && rightPressurePercent != nil
            && hasText(leftPressureImageUrl)
            && hasText(rightPressureImageUrl)
            && hasText(leftPlantarFootprintImageUrl)
            && hasText(rightPlantarFootprintImageUrl)
            && plantarFootprintAnalysisText != nil
            && userFootSize != nil
            && measuredLeftFootSizeMm != nil
            && measuredRightFootSizeMm != nil
            && leftFootSizeDiff != nil
            && rightFootSizeDiff != nil
            && leftFootWidthMm != nil
            && rightFootWidthMm != nil
            && beforeTemperatureCelsius != nil
            && beforeHumidityPercent != nil
            && afterTemperatureCelsius != nil
            && afterHumidityPercent != nil
            && avgTemperatureCelsius != nil
            && avgHumidityPercent != nil
    }

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
        Int((balanceScore ?? 0).rounded())
    }

    var balanceScoreDiffInt: Int? {
        balanceScoreDiff.map { Int($0.rounded()) }
    }

    var leftPressureInt: Int {
        Int((leftPressurePercent ?? 0).rounded())
    }

    var rightPressureInt: Int {
        Int((rightPressurePercent ?? 0).rounded())
    }

    var temperatureValue: Double {
        avgTemperatureCelsius ?? 0
    }

    var humidityValue: Double {
        avgHumidityPercent ?? 0
    }

    // before/after 값이 없을 경우 평균값으로 대체해, 이전=이후=평균으로 표시(마커가 같은 위치에 겹침)한다.
    var beforeTemperatureValue: Double {
        beforeTemperatureCelsius ?? temperatureValue
    }

    var afterTemperatureValue: Double {
        afterTemperatureCelsius ?? temperatureValue
    }

    var beforeHumidityValue: Double {
        beforeHumidityPercent ?? humidityValue
    }

    var afterHumidityValue: Double {
        afterHumidityPercent ?? humidityValue
    }

    var footSizeRows: [FootSizeRow] {
        [
            FootSizeRow(
                title: "입력 사이즈",
                left: formatMm(userFootSize),
                leftDiff: nil,
                right: formatMm(userFootSize),
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

    private func formatMm(_ value: Int?) -> String {
        guard let value else { return "-" }
        return "\(value)mm"
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

    private func hasText(_ value: String?) -> Bool {
        guard let value else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
