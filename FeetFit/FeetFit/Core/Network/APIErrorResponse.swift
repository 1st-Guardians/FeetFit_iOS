//
//  APIErrorResponse.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation

struct APIErrorResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}
