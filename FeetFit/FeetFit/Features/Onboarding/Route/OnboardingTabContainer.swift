//
//  OnboardingTabContainer.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import SwiftUI

struct OnboardingTabContainer: View {
    let onFinish: () -> Void
    
    @State private var router = NavigationRouter<OnboardingRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(onFinish: onFinish)
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                    case .login:
                        LoginView(onFinish: onFinish)
                        
                    case .onboardingUserInfo:
                        OnboardingUserInfoView()
                        
                    case .hardwareRegister:
                        HardwareRegisterView(onFinish: onFinish)
                        
                    case .hardwarePairing:
                        HardwarePairingView {
                            router.replace(with: .hardwarePairingFinish)
                        }
                        
                    case .hardwarePairingFinish:
                        HardwarePairingFinishView(onFinish: onFinish)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    OnboardingTabContainer {}
}
