//
//  WeekCalendarView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct WeekCalendarView: View {
    // MARK: - Properties
    
    private let measuredDates: [Date]
    private let calendar = Calendar.current
    
    init(
        measuredDates: [Date] = []
    ) {
        self.measuredDates = measuredDates
    }
    
    private var weekDates: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return []
        }
        
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            weekTitle
            
            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    dayView(date)
                }
            }
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    // MARK: - SubView
    
    private var weekTitle: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text(monthTitle)
                .pretendardFont(.SubTitle)
            
            Text(yearTitle)
                .pretendardFont(.SectionTitle)
                .padding(.bottom, 2)
        }
        .padding(.horizontal, 12)
    }
    
    // MARK: - Functions
    
    private func dayView(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let hasMeasuredRecord = measuredDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }
        
        return VStack(spacing: 8) {
            Text(weekdayText(from: date))
                .pretendardFont(.BlockText)
                .foregroundStyle(weekdayColor(from: date))
            
            Text(dayText(from: date))
                .pretendardFont(.Description)
                .frame(width: 36, height: 36)
                .background {
                    if isToday {
                        Circle()
                            .fill(.gray03)
                    }
                }
                .foregroundStyle(dayTextColor(
                    hasMeasuredRecord: hasMeasuredRecord
                ))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func weekdayText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func dayText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func weekdayColor(from date: Date) -> Color {
        let weekday = calendar.component(.weekday, from: date)
        
        switch weekday {
        case 1:
            return .red01
        case 7:
            return .blue01
        default:
            return .gray01
        }
    }
    
    private func dayTextColor(
        hasMeasuredRecord: Bool
    ) -> Color {
        if hasMeasuredRecord {
            return .primary
        }
        
        return .gray
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        
        return formatter.string(from: Date())
    }
    
    private var yearTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        
        return formatter.string(from: Date())
    }
}

#Preview("Preview") {
    struct ContentView: View {
        private let measuredDates: [Date] = [
            Date(),
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        ]
        
        var body: some View {
            WeekCalendarView(
                measuredDates: measuredDates
            )
        }
    }
    
    return ContentView()
}
