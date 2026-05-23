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
    @State private var selectedSegment: ResultSegment = .overall
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Text("측정날짜: \(formattedSelectedDate)")
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
                .padding(.horizontal, 20)
            
            segmentControl
            
            contentView
        }
        .padding(.top, 16)
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
            OverallResultView()
            
        case .halluxValgus:
            HalluxValgusResultView()
            
        case .athletesFoot:
            AthletesFootResultView()
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
