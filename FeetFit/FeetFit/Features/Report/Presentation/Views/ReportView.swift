//
//  ReportView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct ReportView: View {
    @State private var selectedMenu: ReportMenuType = .resultReport
    @State private var selectedDate: Date = Date()
    
    private let measuredDates: [Date] = [
        Date(),
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -5, to: Date())!
    ]
    
    var body: some View {
        VStack {
            switch selectedMenu {
            case .resultReport:
                ResultView(selectedDate: selectedDate)
                
            case .summary:
                SummaryView()
            }
        }
        .toolbar {
            ToolBarCollection.ReportMenu(selection: $selectedMenu)
            
            if selectedMenu == .resultReport {
                ToolBarCollection.CalendarBtn(
                    selectedDate: $selectedDate,
                    measuredDates: measuredDates
                )
            }
        }
    }
}

#Preview {
    TabBar(initialTab: .report)
}
