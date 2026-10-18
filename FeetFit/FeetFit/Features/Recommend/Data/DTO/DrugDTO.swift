import Foundation

struct DrugListResultDTO: Decodable {
    let hasMeasurement: Bool?
    let reportId: Int?
    let summary: String?
    let summaryStatus: String?
    let summarySource: String?
    let priorities: [DrugPriorityDTO]?
    let category: String?
    let categoryLabel: String?
    let source: String?
    let items: [DrugDTO]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool

    var orderedCategories: [DrugCategory] {
        var categories: [DrugCategory] = []
        for priority in (priorities ?? []).sorted(by: { $0.rank < $1.rank }) {
            guard priority.rank > 0,
                  let category = DrugCategory(rawValue: priority.category),
                  !categories.contains(category) else { continue }
            categories.append(category)
        }
        return categories + DrugCategory.allCases.filter { !categories.contains($0) }
    }
}

struct DrugPriorityDTO: Decodable {
    let rank: Int
    let category: String
}

struct DrugDetailResultDTO: Decodable {
    let drug: DrugDTO
    let permit: DrugPermitDTO?
    let recall: DrugRecallDTO?
    let source: String

    func toDomain(categoryLabel: String) -> ProductInfo {
        var product = drug.toDomain(categoryLabel: categoryLabel, source: source, permit: permit)
        product.detailItems += recall?.detailItems ?? []
        product.recallSourceURL = nonempty(recall?.sourceUrl).flatMap { URL(string: $0) }
        return product
    }
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
    let category: String?
    let detailUrl: String?
    let description: String?
    let permit: DrugPermitDTO?

    func toDomain(categoryLabel: String, source: String?, permit detailPermit: DrugPermitDTO? = nil) -> ProductInfo {
        let permit = detailPermit ?? self.permit
        let imageURL: String
        if let image = nonempty(image) {
            imageURL = URL(string: image)?.scheme == nil
                ? URL(string: image, relativeTo: URL(string: APIConfig.baseURL))?.absoluteURL.absoluteString ?? ""
                : image
        } else {
            imageURL = ""
        }

        return ProductInfo(
            id: id,
            tags: [category.flatMap(DrugCategory.init(rawValue:))?.label ?? categoryLabel]
                + [nonempty(permit?.classification)].compactMap { $0 },
            brand: company ?? "",
            name: name,
            imageURL: imageURL,
            officialURL: (nonempty(permit?.officialUrl) ?? nonempty(detailUrl)).flatMap { URL(string: $0) },
            effects: nonempty(efficacy) ?? nonempty(description),
            usage: nonempty(usage),
            storage: nonempty(storage) ?? nonempty(permit?.storage),
            precautions: nonempty(warning),
            interactions: nonempty(interaction),
            sideEffects: nonempty(sideEffect),
            detailItems: permit?.detailItems ?? [],
            informationSource: source,
            itemSeq: nonempty(permit?.itemSeq) ?? (!id.isEmpty && id.allSatisfy { $0.isASCII && $0.isNumber } ? id : nil),
            category: category.flatMap(DrugCategory.init(rawValue:))
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

struct DrugRecallDTO: Decodable {
    let status: String?
    let checkedAt: String?
    let sourceUrl: String?

    var detailItems: [ProductInfo.DetailItem] {
        var items: [ProductInfo.DetailItem] = [
            .init(title: "회수 조회 결과", value: status == "clear" ? "회수 이력 없음" : "공식 정보 확인 필요")
        ]
        if let checkedAt,
           let date = (try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(checkedAt))
                ?? (try? Date.ISO8601FormatStyle().parse(checkedAt)) {
            items.append(.init(title: "회수 조회 시각", value: date.formatted(date: .numeric, time: .shortened)))
        }
        return items
    }
}

private func nonempty(_ value: String?) -> String? {
    guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
    return value
}
