import Foundation

enum MeasurementGuide: CaseIterable {
    case preparation
    case connecting
    case photoPreparation
    case photoMeasurement
    case recapturePreparation
    case recapturing
    case pressurePreparation
    case pressureMeasurement
    case pressureRetryPreparation
    case analyzing
    case failed

    init(status: MeasurementStatus?, isPhotoRecapture: Bool) {
        switch status {
        case .waitingForPhotoEnvironment:
            self = .photoPreparation
        case .readyForPhotoEnvironment:
            self = .photoMeasurement
        case .capturingPhotoEnvironment:
            self = isPhotoRecapture ? .recapturing : .photoMeasurement
        case .waitingForRecapture:
            self = .recapturePreparation
        case .readyForRecapture:
            self = .recapturing
        case .waitingForPressure:
            self = .pressurePreparation
        case .readyForPressure, .measuringPressure, .readyForPressureRetry:
            self = .pressureMeasurement
        case .waitingForPressureRetry:
            self = .pressureRetryPreparation
        case .analyzing, .completed:
            self = .analyzing
        case .failed:
            self = .failed
        case nil:
            self = .connecting
        }
    }

    var title: String {
        switch self {
        case .preparation: return "측정 시작 준비"
        case .connecting: return "기기 연결 중"
        case .photoPreparation: return "사진 및 온습도 측정 준비"
        case .photoMeasurement: return "사진 및 온습도 측정 중"
        case .recapturePreparation: return "사진 재촬영 준비"
        case .recapturing: return "사진 재촬영 중"
        case .pressurePreparation: return "압력 측정 준비"
        case .pressureMeasurement: return "압력 측정 중"
        case .pressureRetryPreparation: return "압력 재측정 준비"
        case .analyzing: return "분석 중"
        case .failed: return "측정 실패"
        }
    }

    var description: String {
        switch self {
        case .preparation:
            return "양말을 벗고 기기 앞에 서 주세요.\n준비가 되면 아래 버튼을 눌러주세요."
        case .connecting:
            return "잠시만 기다려 주세요."
        case .photoPreparation:
            return "기기에 올라와 발꿈치를 거치대에 맞춰주세요.\n발이 잘 보이도록 하의를 걷어주세요."
        case .photoMeasurement, .recapturing:
            return "정확한 측정을 위해 발을 움직이지 말아 주세요."
        case .recapturePreparation:
            return "측정에 문제가 생겼어요.\n사진과 온습도를 다시 측정합니다."
        case .pressurePreparation:
            return "하얀색 발판을 내리고,\n발꿈치 표시에 맞춰 올라와 주세요."
        case .pressureMeasurement:
            return "양발을 센서 위에 유지하고\n측정이 끝날 때까지 움직이지 말아 주세요."
        case .pressureRetryPreparation:
            return "양발이 센서에 충분히 닿도록\n위치를 조정한 후 다시 측정해 주세요."
        case .analyzing:
            return "측정이 완료되었습니다.\n기기에서 내려와 결과를 기다려 주세요."
        case .failed:
            return "측정 중 문제가 발생했습니다.\n처음부터 다시 시도해 주세요."
        }
    }

    var systemImage: String? {
        switch self {
        case .photoPreparation: return "camera.on.rectangle.fill"
        case .recapturePreparation, .pressureRetryPreparation: return "arrow.trianglehead.2.clockwise.rotate.90"
        case .pressurePreparation: return "shoeprints.fill"
        case .failed: return "exclamationmark.circle.fill"
        default: return nil
        }
    }

    var buttonTitle: String? {
        switch self {
        case .preparation: return "측정 시작하기"
        case .photoPreparation: return "측정 준비 완료"
        case .recapturePreparation: return "재촬영 준비 완료"
        case .pressurePreparation: return "압력 측정 준비 완료"
        case .pressureRetryPreparation: return "재측정 준비 완료"
        case .failed: return "다시 측정하기"
        default: return nil
        }
    }

    var spokenDescription: String? {
        switch self {
        case .preparation, .photoPreparation, .recapturePreparation, .pressurePreparation, .pressureRetryPreparation, .analyzing:
            return description
        default:
            return nil
        }
    }
}
