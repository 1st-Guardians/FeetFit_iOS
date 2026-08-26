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

// 상태 변경 PATCH(/api/measurement-sessions/{id}/status) 응답
struct MeasurementSessionStatusResultDTO: Decodable {
    let id: Int
    let status: MeasurementStatus
    let measurementDurationSec: Int?
}
