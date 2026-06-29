//
//  ShoeDTO.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation

struct ShoeListResultDTO: Decodable {
    let shoes: [ShoeDTO]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let hasNext: Bool
}

struct ShoeDTO: Decodable {
    let id: Int
    let brandName: String
    let shoeName: String
    let shoeUrl: String?
    let price: Int
    let imageUrl: String
    let overallRating: Double
    let clickCount: Int?
    let reviewCount: Int?
    let fitScore: Double?
}

extension ShoeDTO {
    func toDomain() -> ShoeInfo {
        ShoeInfo(
            id: id,
            brand: brandName,
            name: shoeName,
            price: price,
            rating: overallRating,
            fitScore: fitScore,
            interestCount: clickCount ?? 0,
            reviewCount: reviewCount ?? 0,
            imageURL: imageUrl,
            shoeURL: shoeUrl ?? ""
        )
    }
}
