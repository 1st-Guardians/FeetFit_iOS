//
//  CustomCalendarPickerView.swift
//  FeetFit
//
//  Created by 김미주 on 5/24/26.
//

import SwiftUI

struct CustomCalendarPickerView: View {
    @Binding var selectedDate: Date
    
    let measuredDates: [Date]
    var onSelect: (() -> Void)? = nil
    
    @State private var currentMonth: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(
        selectedDate: Binding<Date>,
        measuredDates: [Date],
        onSelect: (() -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.measuredDates = measuredDates
        self.onSelect = onSelect
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 14) {
            headerSection
            
            weekSection
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days.indices, id: \.self) { index in
                    if let date = days[index] {
                        dayCell(date)
                    } else {
                        Color.clear
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
    }
}

// MARK: - SubViews

extension CustomCalendarPickerView {
    private var headerSection: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            Text(monthTitle)
                .pretendardFont(.BlockTitle)
            
            Spacer()
            
            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.black01)
    }
    
    private var weekSection: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                    .frame(height: 24)
            }
        }
    }
    
    private func dayCell(_ date: Date) -> some View {
        let isMeasured = isMeasuredDate(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        
        return Button {
            guard isMeasured else { return }
            
            selectedDate = date
            onSelect?()
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(dayTextColor(
                    isMeasured: isMeasured,
                    isSelected: isSelected
                ))
                .frame(width: 36, height: 36)
                .background {
                    if isSelected {
                        Circle()
                            .fill(.blue01)
                    }
                }
                .overlay {
                    if isToday && !isSelected {
                        Circle()
                            .stroke(.blue01, lineWidth: 1.4)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(!isMeasured)
    }
}

// MARK: - Calendar Logic

extension CustomCalendarPickerView {
    private var weekdays: [String] {
        ["일", "월", "화", "수", "목", "금", "토"]
    }
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: currentMonth)
    }
    
    private var days: [Date?] {
        makeDays()
    }
    
    private func makeDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: currentMonth
        ) else {
            return []
        }
        
        let firstDate = monthInterval.start
        
        guard let dayRange = calendar.range(
            of: .day,
            in: .month,
            for: firstDate
        ) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDate)
        let leadingEmptyCount = firstWeekday - 1
        
        var result: [Date?] = Array(repeating: nil, count: leadingEmptyCount)
        
        for day in dayRange {
            if let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDate
            ) {
                result.append(date)
            }
        }
        
        return result
    }
    
    private func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: currentMonth
        ) else { return }
        
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            currentMonth = newMonth
        }
    }
    
    private func isMeasuredDate(_ date: Date) -> Bool {
        measuredDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }
    }
    
    private func dayTextColor(
        isMeasured: Bool,
        isSelected: Bool
    ) -> Color {
        if isSelected {
            return .white
        }
        
        if isMeasured {
            return .black01
        }
        
        return .gray02
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDate: Date = Date()
        
        private var measuredDates: [Date] {
            [
                Date(),
                Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                Calendar.current.date(byAdding: .day, value: 3, to: Date())!
            ]
        }
        
        var body: some View {
            CustomCalendarPickerView(
                selectedDate: $selectedDate,
                measuredDates: measuredDates
            )
            .padding()
        }
    }
    
    return PreviewWrapper()
}
