//
//  ShoeFeatureComparison.swift
//  FeetFit
//

import Foundation

struct ShoeFeatureComparison: Identifiable {
    let id = UUID()

    let title: String
    let description: String

    let minimumLabel: String
    let maximumLabel: String

    /// 0...1 범위. 비교군(다른 신발들) 평균 위치
    let comparisonValue: CGFloat
    let comparisonValueLabel: String
    /// 0...1 범위. 이 신발의 위치
    let shoeValue: CGFloat
    let shoeValueLabel: String

    let note: String?

    init(
        title: String,
        description: String,
        minimumLabel: String,
        maximumLabel: String,
        comparisonValue: CGFloat,
        comparisonValueLabel: String,
        shoeValue: CGFloat,
        shoeValueLabel: String,
        note: String? = nil
    ) {
        self.title = title
        self.description = description
        self.minimumLabel = minimumLabel
        self.maximumLabel = maximumLabel
        self.comparisonValue = comparisonValue
        self.comparisonValueLabel = comparisonValueLabel
        self.shoeValue = shoeValue
        self.shoeValueLabel = shoeValueLabel
        self.note = note
    }
}

#if DEBUG
extension ShoeFeatureComparison {
    // /api/shoes/{shoeId}/characteristics 예시 응답값 기준으로 계산한 목업
    static let samples: [ShoeFeatureComparison] = [
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.widthSpace.rawValue,
            description: ShoeSpecAttribute.widthSpace.description(for: .medium),
            minimumLabel: ShoeSpecAttribute.widthSpace.minimumLabel,
            maximumLabel: ShoeSpecAttribute.widthSpace.maximumLabel,
            comparisonValue: 0.49,
            comparisonValueLabel: "비교군 평균 95.2 mm",
            shoeValue: 0.37,
            shoeValueLabel: "현재 신발 93.4 mm",
            note: "US 9 기준 측정값 93.4 mm (평균 95.2 mm)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.toeboxSpace.rawValue,
            description: ShoeSpecAttribute.toeboxSpace.description(for: .low),
            minimumLabel: ShoeSpecAttribute.toeboxSpace.minimumLabel,
            maximumLabel: ShoeSpecAttribute.toeboxSpace.maximumLabel,
            comparisonValue: 0.55,
            comparisonValueLabel: "비교군 평균 75.4 mm",
            shoeValue: 0.26,
            shoeValueLabel: "현재 신발 71.2 mm",
            note: "US 9 기준 측정값 71.2 mm (평균 75.4 mm)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.heelHold.rawValue,
            description: ShoeSpecAttribute.heelHold.description(for: .high),
            minimumLabel: ShoeSpecAttribute.heelHold.minimumLabel,
            maximumLabel: ShoeSpecAttribute.heelHold.maximumLabel,
            comparisonValue: 0.57,
            comparisonValueLabel: "비교군 평균 6.5 score",
            shoeValue: 0.84,
            shoeValueLabel: "현재 신발 8.1 score",
            note: "US 9 기준 측정값 8.1 score (평균 6.5 score)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.cushion.rawValue,
            description: ShoeSpecAttribute.cushion.description(for: .low),
            minimumLabel: ShoeSpecAttribute.cushion.minimumLabel,
            maximumLabel: ShoeSpecAttribute.cushion.maximumLabel,
            comparisonValue: 0.5,
            comparisonValueLabel: "비교군 평균 35 HA",
            shoeValue: 0.31,
            shoeValueLabel: "현재 신발 30 HA",
            note: "US 9 기준 측정값 30.0 HA (평균 35.0 HA)"
        ),
        ShoeFeatureComparison(
            title: ShoeSpecAttribute.breathability.rawValue,
            description: ShoeSpecAttribute.breathability.description(for: .medium),
            minimumLabel: ShoeSpecAttribute.breathability.minimumLabel,
            maximumLabel: ShoeSpecAttribute.breathability.maximumLabel,
            comparisonValue: 0.53,
            comparisonValueLabel: "비교군 평균 3.1 score",
            shoeValue: 0.5,
            shoeValueLabel: "현재 신발 3.0 score",
            note: "US 9 기준 측정값 3.0 score (평균 3.1 score)"
        )
    ]
}
#endif
