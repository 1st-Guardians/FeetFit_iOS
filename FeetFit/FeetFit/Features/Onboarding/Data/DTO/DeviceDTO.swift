//
//  DeviceDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation

enum DeviceConnectionType: String, Encodable {
    case bluetooth = "BLUETOOTH"
}

struct DeviceRegisterRequest: Encodable {
    let deviceName: String
    let connectionType: DeviceConnectionType
}

struct DeviceResponse: Decodable {
    let deviceId: Int?
    let deviceName: String?
    let connectionType: String?
    let connectionStatus: String?
    let status: String?
    let deviceConnected: Bool
}
