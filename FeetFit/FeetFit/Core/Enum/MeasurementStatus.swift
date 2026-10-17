//
//  MeasurementStatus.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation

enum MeasurementStatus: String, Codable {
    case waitingForPhotoEnvironment = "WAITING_FOR_PHOTO_ENVIRONMENT"
    case readyForPhotoEnvironment = "READY_FOR_PHOTO_ENVIRONMENT"
    case capturingPhotoEnvironment = "CAPTURING_PHOTO_ENVIRONMENT"
    case waitingForRecapture = "WAITING_FOR_RECAPTURE"
    case readyForRecapture = "READY_FOR_RECAPTURE"
    case waitingForPressure = "WAITING_FOR_PRESSURE"
    case readyForPressure = "READY_FOR_PRESSURE"
    case measuringPressure = "MEASURING_PRESSURE"
    case waitingForPressureRetry = "WAITING_FOR_PRESSURE_RETRY"
    case readyForPressureRetry = "READY_FOR_PRESSURE_RETRY"
    case analyzing = "ANALYZING"
    case completed = "COMPLETED"
    case failed = "FAILED"

    // 상태별 안내 문구. 서버 배포 없이 iOS에서 문구를 관리하기 위해 여기서 관리한다.
    var guideMessage: String {
        switch self {
        case .waitingForPhotoEnvironment:
            return "사진 촬영 및 온습도 측정을 준비해 주세요.\n하얀색 발판을 올리고 유리판 위에 올라와 주세요.\n하얀색 뒷꿈치 가이드에 맞춰 서 주세요."
        case .readyForPhotoEnvironment:
            return "사진 촬영 및 온습도 측정 준비가 완료되었습니다.\n측정을 시작합니다."
        case .capturingPhotoEnvironment:
            return "사진 촬영 및 온습도 측정 중입니다.\n잠시 움직이지 말아 주세요."
        case .waitingForRecapture:
            return "발 위치를 조정한 뒤\n다시 촬영해 주세요."
        case .readyForRecapture:
            return "재촬영 준비가 완료되었습니다.\n사진 재촬영 및 온습도 측정을 시작합니다."
        case .waitingForPressure:
            return "유리판에서 내려온 뒤\n하얀색 발판을 내리고 다시 올라와 주세요."
        case .readyForPressure:
            return "압력 측정 준비가 완료되었습니다.\n압력 측정을 시작합니다."
        case .measuringPressure:
            return "발 압력을 측정하고 있습니다.\n잠시 움직이지 말아 주세요."
        case .waitingForPressureRetry:
            return "압력값이 부족합니다.\n발 위치를 조정하고 다시 측정해 주세요."
        case .readyForPressureRetry:
            return "압력 재측정 준비가 완료되었습니다.\n압력 재측정을 시작합니다."
        case .analyzing:
            return "측정이 완료되었습니다.\n기기에서 내려와 결과를 기다려 주세요."
        case .completed:
            return "분석이 완료되었습니다.\n결과를 확인해 주세요."
        case .failed:
            return "측정 중 문제가 발생했습니다.\n다시 시도해 주세요."
        }
    }
}
