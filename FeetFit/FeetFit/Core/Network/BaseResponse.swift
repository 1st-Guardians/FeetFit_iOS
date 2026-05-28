//
//  BaseResponse.swift
//  FeetFit
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: T?
}

struct EmptyResponse: Decodable {}
