//
//  ReportView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct ReportView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedMenu: ReportMenuType = .resultReport
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            switch selectedMenu {
            case .resultReport:
                ResultView(selectedDate: selectedDate)

            case .summary:
                SummaryView()
            }
        }
        .task {
            await calendarViewModel.fetchMeasuredDates(for: selectedDate)
        }
        .toolbar {
            ToolBarCollection.ReportMenu(selection: $selectedMenu)

            if selectedMenu == .resultReport {
                ToolBarCollection.CalendarBtn(
                    selectedDate: $selectedDate,
                    measuredDates: calendarViewModel.measuredDates,
                    onMonthChange: { monthDate in
                        Task { await calendarViewModel.fetchMeasuredDates(for: monthDate) }
                    }
                )
            }
        }
    }
}

#Preview {
    TabBar(initialTab: .report)
}
