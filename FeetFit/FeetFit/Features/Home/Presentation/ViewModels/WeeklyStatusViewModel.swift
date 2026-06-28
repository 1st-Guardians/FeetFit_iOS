//
//  WeeklyStatusViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Combine

@MainActor
final class WeeklyStatusViewModel: ObservableObject {
    @Published var weeklyStatus: WeeklyStatus?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var todayDate: Date? {
        guard let today = weeklyStatus?.today else { return nil }
        return Self.dateFormatter.date(from: today)
    }

    var homeStatus: HomeStatus {
        guard let status = weeklyStatus else { return .noRecord }
        let todayHasMeasurement = status.dailyStatuses
            .first { $0.date == status.today }?
            .hasMeasurement == true
        if todayHasMeasurement { return .measuredToday }
        if status.hasWeeklyMeasurement { return .notMeasuredToday }
        return .noRecord
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func fetchWeeklyStatus() async {
        isLoading = true
        errorMessage = nil

        do {
            weeklyStatus = try await MeasurementAPI.shared.fetchWeeklyStatus()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
