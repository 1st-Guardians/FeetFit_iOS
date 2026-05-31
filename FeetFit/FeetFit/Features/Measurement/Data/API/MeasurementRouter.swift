//
//  MeasurementRouter.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import Foundation
import Alamofire
import Moya

enum MeasurementRouter {
    case postSessions
}

extension MeasurementRouter: APITargetType {
    var path: String {
        switch self {
        case .postSessions:
            return "/api/measurement-sessions"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSessions:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postSessions:
            return .requestPlain
        }
    }
}
