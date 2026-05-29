//
//  UserRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Moya
import Alamofire

enum UserRouter {
    case setupProfile(request: ProfileSetupRequest)
}

extension UserRouter: APITargetType {
    var path: String {
        switch self {
        case .setupProfile:
            return APIConfig.Path.user + "/profile/setup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .setupProfile:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .setupProfile(let request):
            return .requestJSONEncodable(request)
        }
    }
}
