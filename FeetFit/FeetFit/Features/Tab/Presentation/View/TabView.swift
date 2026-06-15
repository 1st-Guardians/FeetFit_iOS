//
//  TabBar.swift
//  FeetFit
//
//  Created by 김미주 on 4/6/26.
//

import SwiftUI

struct TabBar: View {
    
    // MARK: - Property
    
    @State private var tabCase: TabCase
    @State private var isShowMyPage: Bool = false
    
    // ReportView를 강제로 새로 만들기 위한 ID
    @State private var reportResetID = UUID()

    init(initialTab: TabCase = .home) {
        _tabCase = State(initialValue: initialTab)
    }

    var body: some View {
        TabView(selection: $tabCase) {
            ForEach(TabCase.allCases) { tab in
                Tab(value: tab, role: tab.tabRoloe, content: {
                    tabView(tab)
                }, label: {
                    tabLabel(tab)
                })
            }
        }
        .onChange(of: tabCase) { _, newValue in
            if newValue == .report {
                reportResetID = UUID()
            }
        }
    }
    
    private func tabLabel(_ tab: TabCase) -> some View {
        VStack(alignment: .center) {
            tab.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(tab.title)
        }
    }
    
    @ViewBuilder
    private func tabView(_ tab: TabCase) -> some View {
        switch tab {
        case .home:
            HomeContainer()
            
        case .report:
            NavigationStack {
                ReportView()
                    .id(reportResetID)
            }
            
        case .recommend:
            RecommendListView()
            
        case .mypage:
            MyPageContainer()
        }
    }
}

#Preview {
    TabBar()
}
