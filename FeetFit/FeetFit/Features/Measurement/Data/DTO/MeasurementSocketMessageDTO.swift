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
    let status: MeasurementStatus
    let detail: String?
    let photoCaptureAttempt: Int?
    let remainingPhotoRecaptures: Int?
    let pressureMeasurementAttempt: Int?
    let remainingPressureRetries: Int?
    // 일부 MEASUREMENT_FAILED 메시지에는 내려오지 않을 수 있어 옵셔널로 둔다.
    let statusMessage: String?
    let shouldDisconnect: Bool
    let sentAt: String?

    // MEASUREMENT_FAILED 전용 필드
    let failureReason: MeasurementFailureReason?
    /// 서버가 전달한 실패 문구. 화면에는 로컬 고정 문구를 표시하고 이 값은 로그에 남긴다.
    let failureMessage: String?
    /// 디버깅/로그용 상세 사유. 사용자에게는 노출하지 않는다.
    let failureDetail: String?
}
