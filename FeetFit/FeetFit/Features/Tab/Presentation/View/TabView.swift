//
//  TabBar.swift
//  FeetFit
//
//  Created by 김미주 on 4/6/26.
//

import SwiftUI

struct TabBar: View {
    
    // MARK: - Propery
    
    @State var tabCase: TabCase
    @State var isShowMyPage: Bool = false

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
    }
    
    private func tabLabel(_ tab: TabCase) -> some View {
        VStack(alignment: .center, content: {
            tab.icon
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(tab.title)
        })
    }
    
    @ViewBuilder
    private func tabView(_ tab: TabCase) -> some View {
        switch tab {
        case .home:
            HomeContainer()
        case .report:
            NavigationStack {
                ReportView()
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
