//
//  ShoeInfo.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//
import Foundation

struct ShoeInfo: Identifiable, Codable {
    let id: Int
    let brand: String
    let name: String
    let price: Int
    let rating: Double
    let fitScore: Int
    let interestCount: Int
    let imageURL: String
    
    var formattedPrice: String {
        price.formatted() + "원"
    }
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
}
