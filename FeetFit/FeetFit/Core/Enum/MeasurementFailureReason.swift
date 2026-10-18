//
//  MeasurementFailureReason.swift
//  FeetFit
//

import Foundation

enum MeasurementFailureReason: String, Codable {
    case cameraError = "CAMERA_ERROR"
    case pressureSensorError = "PRESSURE_SENSOR_ERROR"
    case aiServerError = "AI_SERVER_ERROR"
    case hardwareTimeout = "HARDWARE_TIMEOUT"
    case networkError = "NETWORK_ERROR"
    case userCancelled = "USER_CANCELLED"
    case reportSaveError = "REPORT_SAVE_ERROR"
    case invalidCaptureData = "INVALID_CAPTURE_DATA"
    case deviceDisconnected = "DEVICE_DISCONNECTED"
    case tokenExpired = "TOKEN_EXPIRED"
    case unknown = "UNKNOWN"

    // 백엔드가 아직 모르는 실패 사유를 보내더라도 디코딩이 깨지지 않도록 UNKNOWN으로 폴백한다.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = MeasurementFailureReason(rawValue: raw) ?? .unknown
    }
}
