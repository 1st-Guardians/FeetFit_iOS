//
//  ShoeSpecProfile.swift
//  FeetFit
//

import Foundation

enum ShoeSpecAttribute: String, CaseIterable, Identifiable {
    case cushion = "쿠션감"
    case shockAbsorption = "충격 완화"
    case energyReturn = "반발력"
    case widthSpace = "발볼 공간"
    case toeboxSpace = "앞코 공간"
    case heelHold = "뒤꿈치 고정감"
    case breathability = "통기성"

    var id: String { rawValue }

    /// 백엔드 /api/shoes/{shoeId}/characteristics 의 type 값과 매핑
    init?(apiType: String) {
        switch apiType {
        case "CUSHION": self = .cushion
        case "SHOCK_ABSORPTION": self = .shockAbsorption
        case "ENERGY_RETURN": self = .energyReturn
        case "WIDTH_SPACE": self = .widthSpace
        case "TOEBOX_SPACE": self = .toeboxSpace
        case "HEEL_HOLD": self = .heelHold
        case "BREATHABILITY": self = .breathability
        default: return nil
        }
    }

    var minimumLabel: String {
        switch self {
        case .cushion: return "단단함"
        case .widthSpace, .toeboxSpace: return "좁음"
        case .shockAbsorption, .energyReturn, .heelHold, .breathability: return "낮음"
        }
    }

    var maximumLabel: String {
        switch self {
        case .cushion: return "부드러움"
        case .widthSpace, .toeboxSpace: return "넓음"
        case .shockAbsorption, .energyReturn, .heelHold, .breathability: return "높음"
        }
    }

    /// 백엔드가 특성별 설명 문구를 안 내려줘서, 속성 x 레벨 조합별 문구를 iOS에서 관리한다.
    func description(for level: ShoeSpecLevel) -> String {
        switch (self, level) {
        case (.cushion, .low):
            return "발을 디뎠을 때 바닥감이 느껴지는 단단한 쿠션이에요."
        case (.cushion, .medium):
            return "적당한 탄성의 쿠션으로 무난한 착화감을 줘요."
        case (.cushion, .high):
            return "발을 디뎠을 때 폭신하게 눌리는 부드러운 쿠션이에요."

        case (.shockAbsorption, .low):
            return "착지 충격을 흡수하는 힘이 약한 편이에요."
        case (.shockAbsorption, .medium):
            return "충격을 적당히 흡수해 무난하게 착용할 수 있어요."
        case (.shockAbsorption, .high):
            return "착지할 때 발과 관절에 전해지는 충격을 잘 흡수해 줘요."

        case (.energyReturn, .low):
            return "지면을 밀어내는 반발력이 약해 안정적인 걸음에 적합해요."
        case (.energyReturn, .medium):
            return "반발력이 무난해 다양한 활동에 두루 어울려요."
        case (.energyReturn, .high):
            return "지면을 강하게 밀어내는 반발력으로 탄력 있는 걸음을 도와줘요."

        case (.widthSpace, .low):
            return "발볼 공간이 좁은 편이라 발볼이 넓다면 답답할 수 있어요."
        case (.widthSpace, .medium):
            return "발볼 공간이 평균적인 수준이에요."
        case (.widthSpace, .high):
            return "발볼 공간이 넉넉해 발볼이 넓어도 편하게 신을 수 있어요."

        case (.toeboxSpace, .low):
            return "앞코 공간이 좁은 편이라 발가락이 답답하게 느껴질 수 있어요."
        case (.toeboxSpace, .medium):
            return "앞코 공간이 평균적인 수준이에요."
        case (.toeboxSpace, .high):
            return "앞코 공간이 넉넉해 발가락을 편하게 움직일 수 있어요."

        case (.heelHold, .low):
            return "뒤꿈치를 잡아주는 힘이 약한 편이에요."
        case (.heelHold, .medium):
            return "뒤꿈치를 무난하게 잡아줘요."
        case (.heelHold, .high):
            return "뒤꿈치를 안정적으로 잡아줘 걷거나 뛸 때 흔들림이 적어요."

        case (.breathability, .low):
            return "통기성이 낮은 편이라 장시간 착용 시 발이 덥게 느껴질 수 있어요."
        case (.breathability, .medium):
            return "적당한 통기성으로 무난하게 신을 수 있어요."
        case (.breathability, .high):
            return "통기성이 좋아 발이 쾌적한 상태를 유지하기 좋아요."
        }
    }
}

struct ShoeSpecProfileItem: Identifiable {
    let id = UUID()
    let attribute: ShoeSpecAttribute
    let level: ShoeSpecLevel
    let value: Double
    let minValue: Double
    let maxValue: Double

    var normalizedValue: Double {
        let range = maxValue - minValue
        guard range > 0 else { return 0.5 }
        return min(max((value - minValue) / range, 0.0), 1.0)
    }

    var percentageLabel: String {
        "\(Int((normalizedValue * 100).rounded()))%"
    }
}

struct ShoeSpecProfile {
    /// 신발 자체의 객관적 특성 요약. 아직 생성되지 않았거나 데이터가 없으면 nil.
    let summary: String?
    /// 백엔드가 실제로 내려준 특성만 포함 (5~7개, 없는 특성은 임의로 채우지 않음)
    let items: [ShoeSpecProfileItem]

    var radarItems: [RadarChartItem] {
        items.map {
            RadarChartItem(
                title: $0.attribute.rawValue,
                value: $0.normalizedValue,
                valueLabel: $0.percentageLabel
            )
        }
    }
}

#if DEBUG
extension ShoeSpecProfile {
    static let mock = ShoeSpecProfile(
        summary: "발볼 공간은 평균보다 약간 좁고, 뒤꿈치를 안정적으로 잡아주는 편입니다. 쿠션은 푹신한 타입보다 바닥감이 느껴지는 특성에 가깝습니다.",
        items: [
            ShoeSpecProfileItem(attribute: .widthSpace, level: .medium, value: 93.4, minValue: 70, maxValue: 120),
            ShoeSpecProfileItem(attribute: .toeboxSpace, level: .low, value: 71.2, minValue: 55, maxValue: 100),
            ShoeSpecProfileItem(attribute: .heelHold, level: .high, value: 8.1, minValue: 0, maxValue: 10),
            ShoeSpecProfileItem(attribute: .cushion, level: .low, value: 30.0, minValue: 20, maxValue: 80),
            ShoeSpecProfileItem(attribute: .breathability, level: .medium, value: 3.0, minValue: 1, maxValue: 5)
        ]
    )
}
#endif
