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
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSummary, .getDailyFootAnalysis, .getHalluxValgus:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getSummary:
            return .requestPlain

        case .getDailyFootAnalysis(let date),
             .getHalluxValgus(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getSummary, .getDailyFootAnalysis, .getHalluxValgus:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
