//
//  ResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/21/26.
//

import SwiftUI

struct ResultView: View {
    
    // MARK: - Properties
    
    @State private var selectedSegment: ResultSegment = .overall
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            segmentControl
            
            contentView
            
            Spacer()
        }
        .padding(.horizontal, 20)
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
}

#Preview {
    ResultView()
}
