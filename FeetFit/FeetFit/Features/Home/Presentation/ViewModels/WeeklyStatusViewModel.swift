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

    var homeStatus: HomeStatus {
        guard let status = weeklyStatus else { return .noRecord }
        let todayHasMeasurement = status.dailyStatuses
            .first { $0.date == status.today }?
            .hasMeasurement == true
        if todayHasMeasurement { return .measuredToday }
        if status.hasWeeklyMeasurement { return .notMeasuredToday }
        return .noRecord
    }

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
