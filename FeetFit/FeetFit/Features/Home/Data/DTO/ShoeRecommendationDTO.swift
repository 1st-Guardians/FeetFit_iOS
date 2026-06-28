//
//  ShoeRecommendationDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation

struct ShoeRecommendationsResultDTO: Decodable {
    let shoes: [RecommendedShoeDTO]
}

struct RecommendedShoeDTO: Decodable {
    let id: Int
    let brandName: String
    let shoeName: String
    let shoeUrl: String
    let price: Int
    let imageUrl: String
    let overallRating: Double
    let fitScore: Double
}

extension RecommendedShoeDTO {
    var toDomain: ShoeInfo {
        ShoeInfo(
            id: id,
            brand: brandName,
            name: shoeName,
            price: price,
            rating: overallRating,
            fitScore: fitScore,
            interestCount: 0,
            reviewCount: 0,
            imageURL: imageUrl,
            shoeURL: shoeUrl
        )
    }
}
