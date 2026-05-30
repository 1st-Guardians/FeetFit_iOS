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
}

extension ReportRouter: APITargetType {
    var path: String {
        switch self {
        case .getSummary:
            return APIConfig.Path.report + "/summary"

        case .getDailyFootAnalysis:
            return APIConfig.Path.report + "/daily-foot-analysis"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSummary, .getDailyFootAnalysis:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getSummary:
            return .requestPlain
            
        // 종합 결과 리포트
        case .getDailyFootAnalysis(let date):
            return .requestParameters(
                parameters: ["date": date],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getSummary, .getDailyFootAnalysis:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
