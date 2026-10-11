//
//  ResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/21/26.
//

import SwiftUI

struct ResultView: View {
    
    // MARK: - Properties
    
    let selectedDate: Date
    let showsInlineDate: Bool
    @State private var selectedSegment: ResultSegment = .overall

    init(selectedDate: Date, showsInlineDate: Bool = true) {
        self.selectedDate = selectedDate
        self.showsInlineDate = showsInlineDate
    }
    
    // MARK: - Body
    
    @ViewBuilder
    var body: some View {
        if showsInlineDate {
            reportContent
        } else {
            reportContent
                .modifier(ReportPDFShareModifier(selectedDate: selectedDate))
        }
    }

    private var reportContent: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if showsInlineDate {
                Text("측정날짜: \(formattedSelectedDate)")
                    .pretendardFont(.Caption)
                    .foregroundStyle(.gray01)
                    .padding(.horizontal, 20)
            }
            
            segmentControl
            
            contentView
        }
        .padding(.top, 16)
        .navigationTitle(showsInlineDate ? "" : formattedSelectedDate)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - SubView
    
    private var segmentControl: some View {
        Picker("결과 유형", selection: $selectedSegment) {
            ForEach(ResultSegment.allCases) { segment in
                Text(segment.rawValue)
                    .tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedSegment {
        case .overall:
            OverallResultView(selectedDate: selectedDate)
            
        case .halluxValgus:
            HalluxValgusResultView(selectedDate: selectedDate)
            
        case .athletesFoot:
            AthletesFootResultView(selectedDate: selectedDate)
        }
    }
    
    // MARK: - Helper
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: selectedDate)
    }
}

#Preview {
    ResultView(selectedDate: Date())
}
