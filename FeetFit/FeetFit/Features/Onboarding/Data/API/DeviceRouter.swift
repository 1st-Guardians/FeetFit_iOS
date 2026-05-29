//
//  DeviceRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Moya
import Alamofire

enum DeviceRouter {
    case registerDevice(request: DeviceRegisterRequest)
    case deleteDevice
}

extension DeviceRouter: APITargetType {
    var path: String {
        switch self {
        case .registerDevice:
            return APIConfig.Path.device
            
        case .deleteDevice:
            return APIConfig.Path.device
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .registerDevice:
            return .post
            
        case .deleteDevice:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .registerDevice(let request):
            return .requestJSONEncodable(request)
            
        case .deleteDevice:
            return .requestPlain
        }
    }
}
