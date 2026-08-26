//
//  ShoeFeatureComparison.swift
//  FeetFit
//

import Foundation

struct ShoeFeatureComparison: Identifiable, Codable {
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
    static let samples: [ShoeFeatureComparison] = [
        ShoeFeatureComparison(
            title: "쿠션감",
            levelText: "높음",
            description: "발을 디뎠을 때 폭신하게 눌리는 편이에요.",
            minimumLabel: "단단함",
            maximumLabel: "부드러움",
            comparisonValue: 0.5,
            shoeValue: 0.65,
            note: "※ AC 값은 낮을수록 더 부드러움"
        ),
        ShoeFeatureComparison(
            title: "충격 완화",
            levelText: "높음",
            description: "착지할 때 발과 관절에 전해지는 충격을 잘 흡수해 줘요.",
            minimumLabel: "낮음",
            maximumLabel: "높음",
            comparisonValue: 0.5,
            shoeValue: 0.72
        ),
        ShoeFeatureComparison(
            title: "반발력",
            levelText: "낮음",
            description: "지면을 밀어내는 힘이 약한 편이라 안정적인 걸음에 적합해요.",
            minimumLabel: "낮음",
            maximumLabel: "높음",
            comparisonValue: 0.55,
            shoeValue: 0.3
        ),
        ShoeFeatureComparison(
            title: "발볼 여유",
            levelText: "보통",
            description: "표준적인 발볼 너비에 맞춰 설계돼 있어요.",
            minimumLabel: "좁음",
            maximumLabel: "넓음",
            comparisonValue: 0.45,
            shoeValue: 0.5
        ),
        ShoeFeatureComparison(
            title: "앞코 여유",
            levelText: "높음",
            description: "발가락 앞쪽 공간이 넉넉해 장시간 착용해도 답답함이 적어요.",
            minimumLabel: "좁음",
            maximumLabel: "넓음",
            comparisonValue: 0.5,
            shoeValue: 0.78
        ),
        ShoeFeatureComparison(
            title: "뒤꿈치 고정감",
            levelText: "높음",
            description: "뒤꿈치를 안정적으로 잡아줘 걷거나 뛸 때 흔들림이 적어요.",
            minimumLabel: "낮음",
            maximumLabel: "높음",
            comparisonValue: 0.5,
            shoeValue: 0.8
        ),
        ShoeFeatureComparison(
            title: "통기성",
            levelText: "보통",
            description: "적당한 통기성으로 무난하게 신을 수 있어요.",
            minimumLabel: "낮음",
            maximumLabel: "높음",
            comparisonValue: 0.5,
            shoeValue: 0.48
        )
    ]
}
#endif
