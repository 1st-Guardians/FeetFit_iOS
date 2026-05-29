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
}

extension AuthRouter: APITargetType {
    var path: String {
        switch self {
        case .postKakao:
            return "/api/auth/kakao"
        }
    }

    var method: Moya.Method {
        switch self {
        case .postKakao:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .postKakao(let accessToken):
            return .requestJSONEncodable(
                KakaoLoginRequest(accessToken: accessToken)
            )
        }
    }

    var headers: [String: String]? {
        switch self {
        case .postKakao:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
}
