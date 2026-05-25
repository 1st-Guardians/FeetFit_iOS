//
//  ShoeSortType.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import Foundation

enum ShoeSortType: String, CaseIterable {
    case fit = "발 적합도순"
    case rating = "별점순"
    case interest = "관심도순"
    
    func sort(_ shoes: [ShoeInfo]) -> [ShoeInfo] {
        switch self {
        case .fit:
            return shoes.sorted { $0.fitScore > $1.fitScore }
        case .rating:
            return shoes.sorted { $0.rating > $1.rating }
        case .interest:
            return shoes.sorted { $0.interestCount > $1.interestCount }
        }
    }
}
