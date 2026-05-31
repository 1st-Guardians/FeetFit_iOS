//
//  ReportResultContainerView.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import SwiftUI

enum ReportResultType: String, CaseIterable {
    case overall = "종합"
    case halluxValgus = "무지외반"
    case athletesFoot = "무좀"
}

struct ReportResultContainerView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    @State private var selectedDate: Date = Date()
    @State private var selectedResultType: ReportResultType = .overall
    @State private var isCalendarPresented: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            topSection
            
            resultTypeSection
            
            selectedResultView
        }
        .task {
            await viewModel.fetchMeasuredDates(for: selectedDate)
        }
        .sheet(isPresented: $isCalendarPresented) {
            CustomCalendarPickerView(
                selectedDate: $selectedDate,
                measuredDates: viewModel.measuredDates,
                onSelect: {
                    isCalendarPresented = false
                },
                onMonthChange: { monthDate in
                    Task {
                        await viewModel.fetchMeasuredDates(for: monthDate)
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var topSection: some View {
        HStack {
            Text(formattedSelectedDate)
                .pretendardFont(.BlockTitle)
                .foregroundStyle(.black01)
            
            Spacer()
            
            Button {
                isCalendarPresented = true
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black01)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var resultTypeSection: some View {
        HStack(spacing: 8) {
            ForEach(ReportResultType.allCases, id: \.self) { type in
                Button {
                    selectedResultType = type
                } label: {
                    Text(type.rawValue)
                        .pretendardFont(.Caption)
                        .foregroundStyle(selectedResultType == type ? .white : .black01)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(selectedResultType == type ? .blue01 : .gray03)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private var selectedResultView: some View {
        switch selectedResultType {
        case .overall:
            OverallResultView(selectedDate: selectedDate)
            
        case .halluxValgus:
            HalluxValgusResultView(selectedDate: selectedDate)
            
        case .athletesFoot:
            AthletesFootResultView(selectedDate: selectedDate)
        }
    }
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: selectedDate)
    }
}
