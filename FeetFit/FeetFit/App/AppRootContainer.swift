//
//  AppRootContainer.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import SwiftUI

struct AppRootContainer: View {
    @State private var flow: AppFlow = .splash
    
    var body: some View {
        switch flow {
        case .splash:
            SplashView {
                flow = .onboarding
            }
            
        case .onboarding:
            OnboardingTabContainer {
                flow = .main
            }
            
        case .main:
            TabBar()
        }
    }
}
