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
}
