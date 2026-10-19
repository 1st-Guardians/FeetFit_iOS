//
//  AuthRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Alamofire
import Moya

enum AuthRouter {
    case postKakao(accessToken: String)
    case postApple(code: String)
}

extension AuthRouter: APITargetType {
    var path: String {
        switch self {
        case .postKakao:
            return "/api/auth/kakao"
        case .postApple:
            return "/api/auth/apple"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postKakao, .postApple:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .postKakao(let accessToken):
            return .requestJSONEncodable(
                KakaoLoginRequest(accessToken: accessToken)
            )
        case .postApple(let code):
            return .requestParameters(
                parameters: ["code": code],
                encoding: URLEncoding.httpBody
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .postKakao:
            return [
                "Content-Type": "application/json"
            ]
        case .postApple:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        }
    }
}
