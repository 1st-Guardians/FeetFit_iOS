//
//  ReportView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct ReportView: View {
    @State private var selectedMenu: ReportMenuType = .resultReport
    
    var body: some View {
        VStack {
            switch selectedMenu {
            case .resultReport:
                Text("결과 리포트 화면")
                
            case .summary:
                SummaryView()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolBarCollection.ReportMenu(selection: $selectedMenu)
        }
    }
}

#Preview {
    TabBar(initialTab: .report)
}
