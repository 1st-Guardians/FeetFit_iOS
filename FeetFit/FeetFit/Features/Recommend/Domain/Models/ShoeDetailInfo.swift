//
//  ShoeDetailInfo.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import Foundation

struct ShoeDetailInfo: Identifiable, Codable {
    let id: Int
    
    let brand: String
    let name: String
    let price: Int
    let rating: Double
    let fitScore: Double?
    let interestCount: Int
    let reviewCount: Int
    let imageURL: String
    let shoeURL: String
    
    let summary: String
    let fitPoints: [ShoeFitPoint]
    let analysisCards: [ShoeFitAnalysis]
    
    var formattedPrice: String {
        price.formatted() + "원"
    }
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    var formattedFitScore: String {
        guard let fitScore else {
            return "-"
        }

        return String(format: "%.1f", fitScore)
    }
}

#if DEBUG
extension ShoeDetailInfo {
    static let mock = ShoeDetailInfo(
        id: 1,
        brand: "나이키",
        name: "에어맥스 2026",
        price: 189000,
        rating: 4.5,
        fitScore: 87.3,
        interestCount: 128,
        reviewCount: 342,
        imageURL: "https://picsum.photos/seed/feetfit-shoe/800/800",
        shoeURL: "https://example.com",
        summary: "발볼이 넉넉하고 뒤꿈치 안정감이 좋아 오래 걸어도 편안한 신발이에요.",
        fitPoints: [
            ShoeFitPoint(id: 1, type: .width, status: .good),
            ShoeFitPoint(id: 2, type: .heel, status: .warn),
            ShoeFitPoint(id: 3, type: .insole, status: .bad)
        ],
        analysisCards: [
            ShoeFitAnalysis(
                id: 1,
                title: "발볼 적합도",
                status: .good,
                reviewQuotes: ["발볼이 넓어서 편해요", "여유있게 잘 맞아요"],
                description: "사용자 발 압력 분석 결과, 발볼이 넉넉한 편이라 편안한 착화감을 제공합니다."
            ),
            ShoeFitAnalysis(
                id: 2,
                title: "뒤꿈치 안정감",
                status: .warn,
                reviewQuotes: ["뒤꿈치가 살짝 뜨는 느낌이에요"],
                description: "뒤꿈치 착화감은 보통 수준으로, 장시간 착용 시 밀착감이 다소 아쉬울 수 있습니다."
            ),
            ShoeFitAnalysis(
                id: 3,
                title: "깔창 압력 분산",
                status: .bad,
                reviewQuotes: ["깔창이 좀 얇아요"],
                description: "깔창의 압력 분산 성능이 낮은 편으로, 장시간 착용 시 발바닥 피로도가 높아질 수 있습니다."
            )
        ]
    )
}
#endif
