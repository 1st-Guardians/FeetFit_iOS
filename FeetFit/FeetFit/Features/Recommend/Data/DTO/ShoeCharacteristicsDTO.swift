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

// 백엔드가 예시 스펙과 달리 개별 필드를 null로 내려보내는 경우가 있어,
// 전부 옵셔널로 두고 항목 단위로 무결성을 걸러낸다 (한 필드가 null이어도 전체 디코딩이 깨지지 않도록).
struct ShoeCharacteristicDTO: Decodable {
    let type: String?
    let level: String?
    let value: Double?
    let averageValue: Double?
    let minValue: Double?
    let maxValue: Double?
    let unit: String?
    let testedSize: String?
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
        type.flatMap { ShoeSpecAttribute(apiType: $0) }
    }

    var specLevel: ShoeSpecLevel? {
        level.flatMap { ShoeSpecLevel(rawValue: $0) }
    }

    /// 존재하지 않는 특성을 0/LOW 등으로 임의 생성하지 않도록, 필수 값이 하나라도 없으면 이 항목 자체를 건너뛴다.
    func toSpecProfileItem() -> ShoeSpecProfileItem? {
        guard let attribute, let specLevel, let value, let minValue, let maxValue else { return nil }
        return ShoeSpecProfileItem(
            attribute: attribute,
            level: specLevel,
            value: value,
            minValue: minValue,
            maxValue: maxValue
        )
    }

    func toFeatureComparison() -> ShoeFeatureComparison? {
        guard let attribute, let specLevel,
              let value, let averageValue, let minValue, let maxValue else { return nil }

        let range = maxValue - minValue
        let normalizedShoeValue = range > 0 ? (value - minValue) / range : 0.5
        let normalizedAverageValue = range > 0 ? (averageValue - minValue) / range : 0.5

        return ShoeFeatureComparison(
            title: attribute.rawValue,
            description: attribute.description(for: specLevel),
            minimumLabel: attribute.minimumLabel,
            maximumLabel: attribute.maximumLabel,
            comparisonValue: normalizedAverageValue,
            comparisonValueLabel: "비교군 평균 \(formattedValue(averageValue))",
            shoeValue: normalizedShoeValue,
            shoeValueLabel: "현재 신발 \(formattedValue(value))",
            note: noteText(value: value, averageValue: averageValue)
        )
    }

    func noteText(value: Double, averageValue: Double) -> String {
        let measured = "측정값 \(formattedValue(value)) (평균 \(formattedValue(averageValue)))"

        guard let testedSize, !testedSize.isEmpty else {
            return measured
        }

        return "\(testedSize) 기준 \(measured)"
    }

    func formattedValue(_ number: Double) -> String {
        let unitText = unit ?? ""
        guard !unitText.isEmpty else { return formattedNumber(number) }
        return "\(formattedNumber(number)) \(unitText)"
    }

    func formattedNumber(_ number: Double) -> String {
        number.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(number))
            : String(format: "%.1f", number)
    }
}
