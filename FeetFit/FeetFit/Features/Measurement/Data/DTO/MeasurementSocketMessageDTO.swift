//
//  MeasurementSocketMessageDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation

struct MeasurementSocketMessageDTO: Decodable {
    let eventType: String
    let measurementSessionId: Int
    let userId: Int
    let deviceId: Int
    let deviceName: String
    let status: String
    let shouldDisconnect: Bool
    let sentAt: String
}
