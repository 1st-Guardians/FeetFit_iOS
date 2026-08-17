//
//  TabRouter.swift
//  FeetFit
//

import Foundation
import Combine

@MainActor
final class TabRouter: ObservableObject {
    @Published var selectedTab: TabCase

    init(selectedTab: TabCase = .home) {
        self.selectedTab = selectedTab
    }
}
