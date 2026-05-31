//
//  ReportRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import Alamofire
import Moya

enum ReportRouter {
    case getSummary
    case getDailyFootAnalysis(date: String)
    case getHalluxValgus(date: String)
    case getAthletesFoot(date: String)
    case getMeasuredDates(year: Int, month: Int)
}

extension ReportRouter: APITargetType {
    var path: String {
        switch self {
        case .getSummary:
            return APIConfig.Path.report + "/summary"
            
        case .getDailyFootAnalysis:
            return APIConfig.Path.report + "/daily-foot-analysis"
            
        case .getHalluxValgus:
            return APIConfig.Path.report + "/hallux-valgus"
            
        case .getAthletesFoot:
            return APIConfig.Path.report + "/tina-pedis"
            
        case .getMeasuredDates:
            return APIConfig.Path.report + "/measured-dates"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSummary,
             .getDailyFootAnalysis,
             .getHalluxValgus,
             .getAthletesFoot,
             .getMeasuredDates:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getSummary:
            return .requestPlain
            
        case .getDailyFootAnalysis(let date),
             .getHalluxValgus(let date),
             .getAthletesFoot(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
            
        case .getMeasuredDates(let year, let month):
            return .requestParameters(
                parameters: [
                    "year": year,
                    "month": month
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
