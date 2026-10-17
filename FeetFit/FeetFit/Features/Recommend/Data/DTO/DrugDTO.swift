import Foundation

struct DrugListResultDTO: Decodable {
    let category: String
    let categoryLabel: String
    let source: String
    let items: [DrugDTO]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

struct DrugDTO: Decodable {
    let id: String
    let name: String
    let company: String?
    let image: String?
    let efficacy: String?
    let usage: String?
    let warning: String?
    let interaction: String?
    let sideEffect: String?
    let storage: String?
    let detailUrl: String?
    let description: String?
    let permit: DrugPermitDTO?

    func toDomain(categoryLabel: String, source: String) -> ProductInfo {
        ProductInfo(
            id: id,
            tags: [categoryLabel],
            brand: company ?? "",
            name: name,
            imageURL: image ?? "",
            officialURL: (nonempty(permit?.officialUrl) ?? nonempty(detailUrl)).flatMap { URL(string: $0) },
            effects: nonempty(efficacy) ?? nonempty(description),
            usage: nonempty(usage),
            storage: nonempty(storage) ?? nonempty(permit?.storage),
            precautions: nonempty(warning),
            interactions: nonempty(interaction),
            sideEffects: nonempty(sideEffect),
            detailItems: permit?.detailItems ?? [],
            informationSource: source
        )
    }
}

struct DrugPermitDTO: Decodable {
    let itemSeq: String?
    let englishName: String?
    let classification: String?
    let status: String?
    let cancelled: Bool?
    let permitDate: String?
    let permitType: String?
    let appearance: String?
    let mainIngredient: String?
    let packUnit: String?
    let storage: String?
    let validTerm: String?
    let atcCode: String?
    let officialUrl: String?

    var detailItems: [ProductInfo.DetailItem] {
        let values: [(String, String?)] = [
            ("품목기준코드", itemSeq),
            ("영문명", englishName),
            ("의약품 분류", classification),
            ("허가 상태", nonempty(status) ?? cancelled.map { $0 ? "허가 취소" : "허가 정상" }),
            ("허가일", permitDate),
            ("허가 구분", permitType),
            ("성상", appearance),
            ("주성분", mainIngredient),
            ("포장 단위", packUnit),
            ("저장 방법", storage),
            ("사용 기간", validTerm),
            ("ATC 코드", atcCode)
        ]
        return values.compactMap { title, value in
            guard let value = nonempty(value) else { return nil }
            return .init(title: title, value: value)
        }
    }
}

private func nonempty(_ value: String?) -> String? {
    guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
    return value
}
