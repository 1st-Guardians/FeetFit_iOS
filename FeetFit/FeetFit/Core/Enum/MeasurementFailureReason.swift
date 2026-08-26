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

    /// 백엔드가 failureMessage를 내려주지 않을 때 사용하는 로컬 폴백 문구.
    var fallbackMessage: String {
        switch self {
        case .cameraError:
            return "사진 촬영 중 문제가 발생했습니다.\n다시 촬영해 주세요."
        case .pressureSensorError:
            return "압력 센서 측정 중 문제가 발생했습니다.\n다시 시도해 주세요."
        case .aiServerError:
            return "분석 서버에서 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        case .hardwareTimeout:
            return "기기 응답이 지연되고 있어요.\n다시 시도해 주세요."
        case .networkError:
            return "네트워크 통신 중 문제가 발생했습니다.\n다시 시도해 주세요."
        case .userCancelled:
            return "측정이 취소되었습니다."
        case .reportSaveError:
            return "측정 결과를 저장하지 못했습니다.\n다시 시도해 주세요."
        case .invalidCaptureData:
            return "측정 데이터가 올바르지 않습니다.\n다시 측정해 주세요."
        case .deviceDisconnected:
            return "기기 연결이 끊겼습니다.\n연결 상태를 확인하고 다시 시도해 주세요."
        case .tokenExpired:
            return "로그인이 만료되었습니다.\n다시 로그인해 주세요."
        case .unknown:
            return "측정 중 문제가 발생했습니다.\n다시 시도해 주세요."
        }
    }
}
