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
    let fitScore: Double?
    let interestCount: Int
    let reviewCount: Int
    let imageURL: String
    let shoeURL: String
    
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
