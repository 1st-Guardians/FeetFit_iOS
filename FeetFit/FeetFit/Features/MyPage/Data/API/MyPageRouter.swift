//
//  MyPageRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation
import Moya
import Alamofire

enum MyPageRouter {
    case getProfile
    case updateProfile(request: MyPageProfileUpdateRequest)
}

extension MyPageRouter: APITargetType {
    var path: String {
        switch self {
        case .getProfile, .updateProfile:
            return APIConfig.Path.user + "/profile"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
        case .updateProfile:
            return .patch
        }
    }
    
    var task: Task {
        switch self {
        case .getProfile:
            return .requestPlain
            
        case .updateProfile(let request):
            return .requestJSONEncodable(request)
        }
    }
}
