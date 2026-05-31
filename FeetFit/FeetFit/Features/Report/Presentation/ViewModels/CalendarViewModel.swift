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
    
    func fetchMeasuredDates(for monthDate: Date) async {
        isLoadingMeasuredDates = true
        errorMessage = nil
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: monthDate)
        let month = calendar.component(.month, from: monthDate)
        
        do {
            measuredDates = try await ReportAPI.shared.fetchMeasuredDates(
                year: year,
                month: month
            )
        } catch {
            errorMessage = error.localizedDescription
            measuredDates = []
        }
        
        isLoadingMeasuredDates = false
    }
}
