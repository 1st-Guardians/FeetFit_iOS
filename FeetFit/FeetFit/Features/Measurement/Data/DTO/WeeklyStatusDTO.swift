//
//  WeeklyStatusDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation

struct WeeklyStatusResultDTO: Decodable {
    let today: String
    let weekStartDate: String
    let weekEndDate: String
    let hasWeeklyMeasurement: Bool
    let dailyStatuses: [DailyStatusDTO]
}

struct DailyStatusDTO: Decodable {
    let date: String
    let dayOfWeek: String
    let dayOfWeekKor: String
    let hasMeasurement: Bool
}

extension WeeklyStatusResultDTO {
    var toDomain: WeeklyStatus {
        WeeklyStatus(
            today: today,
            hasWeeklyMeasurement: hasWeeklyMeasurement,
            dailyStatuses: dailyStatuses.map { $0.toDomain }
        )
    }
}

extension DailyStatusDTO {
    var toDomain: DailyStatus {
        DailyStatus(
            date: date,
            dayOfWeekKor: dayOfWeekKor,
            hasMeasurement: hasMeasurement
        )
    }
}
