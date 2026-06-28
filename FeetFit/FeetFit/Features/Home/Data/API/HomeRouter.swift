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
    case getArticles
    case patchTodoCompletion(todoId: Int, isCompleted: Bool)
}

extension HomeRouter: APITargetType {
    var path: String {
        switch self {
        case .getStretchingTodos:
            return "/api/stretching-todos"
        case .getArticles:
            return "/api/articles"
        case .patchTodoCompletion(let todoId, _):
            return "/api/stretching-todos/\(todoId)/completion"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getStretchingTodos,
             .getArticles:
            return .get
        case .patchTodoCompletion:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .getStretchingTodos,
             .getArticles:
            return .requestPlain
        case .patchTodoCompletion(_, let isCompleted):
            return .requestParameters(
                parameters: ["isCompleted": isCompleted],
                encoding: JSONEncoding.default
            )
        }
    }
}
