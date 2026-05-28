//
//  APITargetType.swift
//  FeetFit
//
//  Created by 김미주 on 5/27/26.
//

import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid baseURL")
        }
        return url
    }

    var headers: [String: String]? {
        switch task {
        case .requestJSONEncodable, .requestParameters:
            return ["Content-Type": "application/json"]
        case .uploadMultipart:
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }

    var validationType: ValidationType {
        .successCodes
    }
}
