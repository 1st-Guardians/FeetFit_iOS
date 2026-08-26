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
    // 일부 MEASUREMENT_FAILED 메시지에는 내려오지 않을 수 있어 옵셔널로 둔다.
    let statusMessage: String?
    let shouldDisconnect: Bool
    let sentAt: String?

    // MEASUREMENT_FAILED 전용 필드
    let failureReason: MeasurementFailureReason?
    /// 사용자에게 그대로 보여줄 실패 문구 (백엔드 제공)
    let failureMessage: String?
    /// 디버깅/로그용 상세 사유. 사용자에게는 노출하지 않는다.
    let failureDetail: String?
}
