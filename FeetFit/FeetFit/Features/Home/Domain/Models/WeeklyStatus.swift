//
//  WeeklyStatus.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation

struct WeeklyStatus {
    let today: String
    let hasWeeklyMeasurement: Bool
    let dailyStatuses: [DailyStatus]
}

struct DailyStatus {
    let date: String
    let dayOfWeekKor: String
    let hasMeasurement: Bool
}
