//
//  ShoeSearchDTO.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation

struct ShoeSearchResultDTO: Decodable {
    let results: [ShoeSearchItemDTO]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

struct ShoeSearchItemDTO: Decodable {
    let id: Int
    let brandName: String
    let shoeName: String
    let price: Int
    let imageUrl: String
    let overallRating: Double
}

extension ShoeSearchItemDTO {
    func toDomain() -> ShoeInfo {
        ShoeInfo(
            id: id,
            brand: brandName,
            name: shoeName,
            price: price,
            rating: overallRating,
            fitScore: nil,
            interestCount: 0,
            reviewCount: 0,
            imageURL: imageUrl,
            shoeURL: ""
        )
    }
}
