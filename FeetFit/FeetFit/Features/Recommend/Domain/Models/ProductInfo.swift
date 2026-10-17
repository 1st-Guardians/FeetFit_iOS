import Foundation

struct ProductInfo: Identifiable, Hashable {
    let id: Int
    let tags: [String]
    let brand: String
    let name: String
    let imageURL: String
    var officialURL: URL?
    var effects: String?
    var usage: String?
    var storage: String?
    var precautions: String?
    var details: String?

    var tag: String {
        tags.first ?? ""
    }

    static let samples: [ProductInfo] = [
        ProductInfo(id: 1, tags: ["보습"], brand: "샘플 브랜드", name: "풋 보습 크림", imageURL: ""),
        ProductInfo(id: 2, tags: ["발 관리"], brand: "샘플 브랜드", name: "발 각질 케어 패드", imageURL: ""),
        ProductInfo(id: 3, tags: ["위생"], brand: "샘플 브랜드", name: "풋 클렌징 스프레이", imageURL: ""),
        ProductInfo(id: 4, tags: ["쿠션"], brand: "샘플 브랜드", name: "뒤꿈치 보호 패드", imageURL: ""),
        ProductInfo(id: 5, tags: ["발 관리"], brand: "샘플 브랜드", name: "발 마사지 볼", imageURL: "")
    ]
}
