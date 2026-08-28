//
//  ShoeCharacteristicsDTO.swift
//  FeetFit
//

import Foundation

struct ShoeCharacteristicsResultDTO: Decodable {
    let shoeId: Int
    let summary: String?
    let characteristics: [ShoeCharacteristicDTO]
}

struct ShoeCharacteristicDTO: Decodable {
    let type: String
    let level: String
    let value: Double
    let averageValue: Double
    let minValue: Double
    let maxValue: Double
    let unit: String
    let testedSize: String
}

extension ShoeCharacteristicsResultDTO {
    /// 특성이 하나도 없으면(RunRepeat 데이터 없음) nil을 반환해 "상품정보" 탭이 준비중 플레이스홀더로 빠지게 한다.
    func toSpecProfile() -> ShoeSpecProfile? {
        let items = characteristics.compactMap { $0.toSpecProfileItem() }

        guard !items.isEmpty else { return nil }

        return ShoeSpecProfile(summary: summary, items: items)
    }

    func toFeatureComparisons() -> [ShoeFeatureComparison] {
        characteristics.compactMap { $0.toFeatureComparison() }
    }
}

private extension ShoeCharacteristicDTO {
    var attribute: ShoeSpecAttribute? {
        ShoeSpecAttribute(apiType: type)
    }

    var specLevel: ShoeSpecLevel? {
        ShoeSpecLevel(rawValue: level)
    }

    func toSpecProfileItem() -> ShoeSpecProfileItem? {
        guard let attribute, let specLevel else { return nil }
        return ShoeSpecProfileItem(attribute: attribute, level: specLevel)
    }

    func toFeatureComparison() -> ShoeFeatureComparison? {
        guard let attribute, let specLevel else { return nil }

        let range = maxValue - minValue
        let normalizedShoeValue = range > 0 ? (value - minValue) / range : 0.5
        let normalizedAverageValue = range > 0 ? (averageValue - minValue) / range : 0.5

        return ShoeFeatureComparison(
            title: attribute.rawValue,
            levelText: specLevel.title,
            description: attribute.description(for: specLevel),
            minimumLabel: attribute.minimumLabel,
            maximumLabel: attribute.maximumLabel,
            comparisonValue: normalizedAverageValue,
            shoeValue: normalizedShoeValue,
            note: "\(testedSize) 기준 측정값 \(formattedNumber(value)) \(unit) (평균 \(formattedNumber(averageValue)) \(unit))"
        )
    }

    func formattedNumber(_ number: Double) -> String {
        number.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(number))
            : String(format: "%.1f", number)
    }
}
