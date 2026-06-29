//
//  ShoeRecommendationDTO.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation

struct ShoeRecommendationResultDTO: Decodable {
    let shoes: [ShoeRecommendationDTO]
}

struct ShoeRecommendationDTO: Decodable {
    let id: Int
    let brandName: String
    let shoeName: String
    let price: Int
    let imageUrl: String
    let overallRating: Double
    let fitScore: Double?
}

extension ShoeRecommendationDTO {
    func toDomain() -> ShoeInfo {
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
            shoeURL: ""
        )
    }
}
