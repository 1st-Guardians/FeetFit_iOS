//
//  WeekCalendarView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct WeekCalendarView: View {
    // MARK: - Properties

    private let dailyStatuses: [DailyStatus]
    private let onDateSelected: ((Date) -> Void)?

    init(
        dailyStatuses: [DailyStatus] = [],
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self.dailyStatuses = dailyStatuses
        self.onDateSelected = onDateSelected
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            weekTitle

            HStack(spacing: 8) {
                ForEach(Array(dailyStatuses.enumerated()), id: \.offset) { index, status in
                    dayView(status, weekdayIndex: index)
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

    private func dayView(_ status: DailyStatus, weekdayIndex: Int) -> some View {
        let isToday = (status.date == todayString)

        let cell = VStack(spacing: 8) {
            Text(status.dayOfWeekKor)
                .pretendardFont(.BlockText)
                .foregroundStyle(weekdayColor(for: weekdayIndex))

            Text(dayText(from: status.date))
                .pretendardFont(.Description)
                .frame(width: 36, height: 36)
                .background {
                    if isToday {
                        Circle()
                            .fill(.gray03)
                    }
                }
                .foregroundStyle(status.hasMeasurement ? weekdayColor(for: weekdayIndex) : Color.gray)
        }
        .frame(maxWidth: .infinity)

        return Group {
            if status.hasMeasurement {
                Button {
                    if let date = Self.dateFormatter.date(from: status.date) {
                        onDateSelected?(date)
                    }
                } label: {
                    cell
                }
                .buttonStyle(.plain)
            } else {
                cell
            }
        }
    }

    private func weekdayColor(for index: Int) -> Color {
        switch index {
        case 0: return .red01
        case 6: return .blue01
        default: return .gray01
        }
    }

    private func dayText(from dateStr: String) -> String {
        guard let date = Self.dateFormatter.date(from: dateStr) else { return "" }
        return Self.dayNumberFormatter.string(from: date)
    }

    private var todayString: String {
        Self.dateFormatter.string(from: Date())
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    private static let dayNumberFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

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
    WeekCalendarView(
        dailyStatuses: [
            DailyStatus(date: "2026-06-22", dayOfWeekKor: "일", hasMeasurement: false),
            DailyStatus(date: "2026-06-23", dayOfWeekKor: "월", hasMeasurement: true),
            DailyStatus(date: "2026-06-24", dayOfWeekKor: "화", hasMeasurement: false),
            DailyStatus(date: "2026-06-25", dayOfWeekKor: "수", hasMeasurement: true),
            DailyStatus(date: "2026-06-26", dayOfWeekKor: "목", hasMeasurement: false),
            DailyStatus(date: "2026-06-27", dayOfWeekKor: "금", hasMeasurement: false),
            DailyStatus(date: "2026-06-28", dayOfWeekKor: "토", hasMeasurement: false)
        ]
    )
}
