//
//  MeasurementSessionDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation

struct MeasurementSessionResultDTO: Decodable {
    let id: Int
    let deviceId: Int
    let status: MeasurementStatus
    let measuredAt: String
    let createdAt: String
    let webSocketTopic: String
}
