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
}

extension ReportRouter: APITargetType {
    var path: String {
        switch self {
        case .getSummary:
            return APIConfig.Path.report + "/summary"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSummary:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getSummary:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .getSummary:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
