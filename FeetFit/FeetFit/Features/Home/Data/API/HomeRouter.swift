//
//  HomeRouter.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Alamofire
import Moya

enum HomeRouter {
    case getStretchingTodos
}

extension HomeRouter: APITargetType {
    var path: String {
        switch self {
        case .getStretchingTodos:
            return "/api/stretching-todos"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getStretchingTodos:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .getStretchingTodos:
            return .requestPlain
        }
    }
}
