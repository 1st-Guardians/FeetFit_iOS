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
    case getWeeklyStatus
    case patchSessionStatus(sessionId: Int, status: MeasurementStatus, photoCaptureAttempt: Int?)
}

extension MeasurementRouter: APITargetType {
    var path: String {
        switch self {
        case .postSessions:
            return "/api/measurement-sessions"
        case .getWeeklyStatus:
            return "/api/measurement-sessions/weekly-status"
        case .patchSessionStatus(let sessionId, _, _):
            return "/api/measurement-sessions/\(sessionId)/status"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postSessions:
            return .post
        case .getWeeklyStatus:
            return .get
        case .patchSessionStatus:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .postSessions,
             .getWeeklyStatus:
            return .requestPlain
        case .patchSessionStatus(_, let status, let photoCaptureAttempt):
            var parameters: [String: Any] = ["status": status.rawValue]
            if let photoCaptureAttempt {
                parameters["photoCaptureAttempt"] = photoCaptureAttempt
            }

            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding.queryString
            )
        }
    }
}
