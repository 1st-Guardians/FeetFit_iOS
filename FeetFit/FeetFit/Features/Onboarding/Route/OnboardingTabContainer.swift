//
//  OnboardingTabContainer.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import SwiftUI

struct OnboardingTabContainer: View {
    @State private var router = NavigationRouter<OnboardingRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            SplashView()
                .navigationDestination(for:
                    OnboardingRoute.self) { route
                    in
                    switch route {
                    case .login:
                        LoginView()
                    case .onboardingUserInfo:
                        OnboardingUserInfoView()
                    case .hardwareRegister:
                        HardwareRegisterView()
                    case .hardwarePairing:
                        HardwarePairingView()
                    case .hardwarePairingFinish:
                        HardwarePairingFinishView()
                    case .tab:
                        TabBar()
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    OnboardingTabContainer()
}
