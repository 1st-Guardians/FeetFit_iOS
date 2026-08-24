//
//  ShoeSpecProfile.swift
//  FeetFit
//

import Foundation

enum ShoeSpecAttribute: String, CaseIterable, Identifiable {
    case cushionSoftness = "쿠션 부드러움"
    case shockAbsorption = "충격 흡수력"
    case rebound = "반발력"
    case forefootSpace = "발볼 공간"
    case toeBoxSpace = "앞코 공간"
    case heelStability = "뒤꿈치 안정성"
    case breathability = "통기성"

    var id: String { rawValue }
}

struct ShoeSpecProfile: Codable {
    let cushionSoftness: ShoeSpecLevel
    let shockAbsorption: ShoeSpecLevel
    let rebound: ShoeSpecLevel
    let forefootSpace: ShoeSpecLevel
    let toeBoxSpace: ShoeSpecLevel
    let heelStability: ShoeSpecLevel
    let breathability: ShoeSpecLevel

    var radarItems: [RadarChartItem] {
        [
            RadarChartItem(
                title: ShoeSpecAttribute.cushionSoftness.rawValue,
                value: cushionSoftness.normalizedValue,
                valueLabel: cushionSoftness.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.shockAbsorption.rawValue,
                value: shockAbsorption.normalizedValue,
                valueLabel: shockAbsorption.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.rebound.rawValue,
                value: rebound.normalizedValue,
                valueLabel: rebound.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.forefootSpace.rawValue,
                value: forefootSpace.normalizedValue,
                valueLabel: forefootSpace.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.toeBoxSpace.rawValue,
                value: toeBoxSpace.normalizedValue,
                valueLabel: toeBoxSpace.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.heelStability.rawValue,
                value: heelStability.normalizedValue,
                valueLabel: heelStability.title
            ),
            RadarChartItem(
                title: ShoeSpecAttribute.breathability.rawValue,
                value: breathability.normalizedValue,
                valueLabel: breathability.title
            )
        ]
    }
}
