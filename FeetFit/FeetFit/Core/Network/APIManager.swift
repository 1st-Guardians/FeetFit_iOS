//
//  APIManager.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Alamofire
import Moya

class APIManager {
    static let shared = APIManager()
    private init() {}

    func createProvider<T: TargetType>(
        for targetType: T.Type,
        withAuth: Bool = true
    ) -> MoyaProvider<T> {
        let session: Session

        if withAuth {
            session = Session(interceptor: AuthInterceptor.shared)
        } else {
            session = Session()
        }

        return MoyaProvider<T>(session: session)
    }
}
