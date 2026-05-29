//
//  NavigationRouter.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class NavigationRouter<Route: Hashable> {
    var path = NavigationPath()
    
    // 추가
    func push(_ route: Route) {
        path.append(route)
    }
    
    // 마지막 화면 제거
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    // 초기화
    func reset() {
        path = NavigationPath()
    }
    
    
    func replace(with route: Route) {
        path = NavigationPath()
        path.append(route)
    }
}

