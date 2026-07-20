//
//  ShoeRoute.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation
import Moya
import Alamofire

enum ShoeRoute {
    case getTopRecommendations
    case getShoes(sort: ShoeSortType, page: Int, size: Int)
    case registerClick(shoeId: Int)
    case getShoeDetail(shoeId: Int)
    case searchShoes(keyword: String, page: Int, size: Int)
    case searchShoeSuggestions(keyword: String, page: Int, size: Int)
    case getSearchHistory
    case deleteSearchHistory(historyId: Int)
    case getFootTypeText
}

extension ShoeRoute: APITargetType {
    var path: String {
        switch self {
        case .getTopRecommendations:
            return "/api/shoes/recommendations/top3"
            
        case .getShoes:
            return "/api/shoes"
            
        case .registerClick(let shoeId):
            return "/api/shoes/\(shoeId)/click"
            
        case .getShoeDetail(let shoeId):
            return "/api/shoes/\(shoeId)"
            
        case .searchShoes:
            return "/api/shoes/search"
            
        case .searchShoeSuggestions:
            return "/api/shoes/search/suggestions"
            
        case .getSearchHistory:
            return "/api/shoes/search/history"
            
        case .deleteSearchHistory(let historyId):
            return "/api/shoes/search/history/\(historyId)"
            
        case .getFootTypeText:
            return "/api/reports/foot-type-text"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getTopRecommendations,
             .getShoes,
             .getShoeDetail,
             .searchShoes,
             .searchShoeSuggestions,
             .getSearchHistory,
             .getFootTypeText:
            return .get
            
        case .registerClick:
            return .post
            
        case .deleteSearchHistory:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getTopRecommendations,
             .registerClick,
             .getShoeDetail,
             .getSearchHistory,
             .deleteSearchHistory,
             .getFootTypeText:
            return .requestPlain
            
        case .getShoes(let sort, let page, let size):
            return .requestParameters(
                parameters: [
                    "sort": sort.apiValue,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
            
        case .searchShoes(let keyword, let page, let size),
             .searchShoeSuggestions(let keyword, let page, let size):
            return .requestParameters(
                parameters: [
                    "keyword": keyword,
                    "page": page,
                    "size": size
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
}
