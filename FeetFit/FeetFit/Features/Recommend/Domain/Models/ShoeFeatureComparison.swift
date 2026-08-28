//
//  ShoeFeatureComparison.swift
//  FeetFit
//

import Foundation

struct ShoeFeatureComparison: Identifiable {
    let id = UUID()

    let title: String
    let levelText: String
    let description: String

    let minimumLabel: String
    let maximumLabel: String

    /// 0...1 범위. 비교군(다른 신발들) 평균 위치
    let comparisonValue: CGFloat
    /// 0...1 범위. 이 신발의 위치
    let shoeValue: CGFloat

    let note: String?

    init(
        title: String,
        levelText: String,
        description: String,
        minimumLabel: String,
        maximumLabel: String,
        comparisonValue: CGFloat,
        shoeValue: CGFloat,
        note: String? = nil
    ) {
        self.title = title
        self.levelText = levelText
        self.description = description
        self.minimumLabel = minimumLabel
        self.maximumLabel = maximumLabel
        self.comparisonValue = comparisonValue
        self.shoeValue = shoeValue
        self.note = note
    }
}

#if DEBUG
extension ShoeFeatureComparison {
    // /api/shoes/{shoeId}/characteristics 예시 응답값 기준으로 계산한 목업
    static let samples: [ShoeFeatureComparison] = [
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.widthSpace.rawValue,
            levelText: ShoeSpecLevel.medium.title,
            description: ShoeSpecAttribute.widthSpace.description(for: .medium),
            minimumLabel: ShoeSpecAttribute.widthSpace.minimumLabel,
            maximumLabel: ShoeSpecAttribute.widthSpace.maximumLabel,
            comparisonValue: 0.49,
            shoeValue: 0.37,
            note: "US 9 기준 측정값 93.4 mm (평균 95.2 mm)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.toeboxSpace.rawValue,
            levelText: ShoeSpecLevel.low.title,
            description: ShoeSpecAttribute.toeboxSpace.description(for: .low),
            minimumLabel: ShoeSpecAttribute.toeboxSpace.minimumLabel,
            maximumLabel: ShoeSpecAttribute.toeboxSpace.maximumLabel,
            comparisonValue: 0.55,
            shoeValue: 0.26,
            note: "US 9 기준 측정값 71.2 mm (평균 75.4 mm)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.heelHold.rawValue,
            levelText: ShoeSpecLevel.high.title,
            description: ShoeSpecAttribute.heelHold.description(for: .high),
            minimumLabel: ShoeSpecAttribute.heelHold.minimumLabel,
            maximumLabel: ShoeSpecAttribute.heelHold.maximumLabel,
            comparisonValue: 0.57,
            shoeValue: 0.84,
            note: "US 9 기준 측정값 8.1 score (평균 6.5 score)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.cushion.rawValue,
            levelText: ShoeSpecLevel.low.title,
            description: ShoeSpecAttribute.cushion.description(for: .low),
            minimumLabel: ShoeSpecAttribute.cushion.minimumLabel,
            maximumLabel: ShoeSpecAttribute.cushion.maximumLabel,
            comparisonValue: 0.5,
            shoeValue: 0.31,
            note: "US 9 기준 측정값 30.0 HA (평균 35.0 HA)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.breathability.rawValue,
            levelText: ShoeSpecLevel.medium.title,
            description: ShoeSpecAttribute.breathability.description(for: .medium),
            minimumLabel: ShoeSpecAttribute.breathability.minimumLabel,
            maximumLabel: ShoeSpecAttribute.breathability.maximumLabel,
            comparisonValue: 0.53,
            shoeValue: 0.5,
            note: "US 9 기준 측정값 3.0 score (평균 3.1 score)"
        )
    ]
}
#endif
