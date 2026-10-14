import Foundation

struct ProductInfo: Identifiable {
    let id: Int
    let tag: String
    let brand: String
    let name: String
    let imageURL: String

    static let samples: [ProductInfo] = [
        ProductInfo(id: 1, tag: "보습", brand: "샘플 브랜드", name: "풋 보습 크림", imageURL: ""),
        ProductInfo(id: 2, tag: "발 관리", brand: "샘플 브랜드", name: "발 각질 케어 패드", imageURL: ""),
        ProductInfo(id: 3, tag: "위생", brand: "샘플 브랜드", name: "풋 클렌징 스프레이", imageURL: ""),
        ProductInfo(id: 4, tag: "쿠션", brand: "샘플 브랜드", name: "뒤꿈치 보호 패드", imageURL: ""),
        ProductInfo(id: 5, tag: "발 관리", brand: "샘플 브랜드", name: "발 마사지 볼", imageURL: "")
    ]
}
