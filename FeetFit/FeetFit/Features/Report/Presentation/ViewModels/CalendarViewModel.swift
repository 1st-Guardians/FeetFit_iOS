//
//  CalendarViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var measuredDates: [Date] = []
    @Published var isLoadingMeasuredDates: Bool = false
    @Published var errorMessage: String?

    private var fetchSequence = 0

    func fetchMeasuredDates(for monthDate: Date) async {
        fetchSequence += 1
        let seq = fetchSequence

        isLoadingMeasuredDates = true
        errorMessage = nil

        let calendar = Calendar.current
        let year = calendar.component(.year, from: monthDate)
        let month = calendar.component(.month, from: monthDate)

        do {
            let dates = try await ReportAPI.shared.fetchMeasuredDates(
                year: year,
                month: month
            )
            guard fetchSequence == seq else { return }
            measuredDates = dates
        } catch {
            guard fetchSequence == seq else { return }
            errorMessage = error.localizedDescription
            measuredDates = []
        }

        isLoadingMeasuredDates = false
    }
}
