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
    case click = "관심도순"
    
    var apiValue: String {
        switch self {
        case .fit:
            return "FIT_SCORE"
        case .rating:
            return "RATING"
        case .click:
            return "CLICK"
        }
    }
}
