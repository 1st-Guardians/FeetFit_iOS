//
//  TabCase.swift
//  FeetFit
//
//  Created by 김미주 on 4/6/26.
//

import SwiftUI

enum TabCase: CaseIterable, Identifiable {
    case home
    case report
    case recommend
    case mypage
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .home: return "홈"
        case .report: return "리포트"
        case .recommend: return "신발추천"
        case .mypage: return "마이페이지"
        }
    }
    
    var icon: Image {
        switch self {
        case .home:
            Image(systemName: "house.fill")
        case .report:
            Image(systemName: "list.clipboard.fill")
        case .recommend:
            Image(systemName: "shoe.fill")
        case .mypage:
            Image(systemName: "person.fill")
        }
    }
    
    var tabRoloe: TabRole? {
        switch self {
        case .mypage:
            return .search
        default:
            return .none
        }
    }
}
