//
//  HardwarePairingView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

//
//  HardwarePairingView.swift
//  FeetFit
//

import SwiftUI
import Lottie

struct HardwarePairingView: View {
    
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @StateObject private var viewModel = HardwarePairingViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "하드웨어를\n연결하고 있어요."
            )
            .padding(.bottom, 277)
            
            MainButton(viewModel.isLoading ? "연결 중..." : "다시 확인하기") {
                viewModel.registerDevice()
            }
            .padding(.horizontal, 18)
            .disabled(viewModel.isLoading)
        }
        .navigationBarBackButtonHidden()
        .task {
            viewModel.registerDevice()
        }
        .onChange(of: viewModel.isConnected) { _, isConnected in
            guard isConnected else { return }
            router.replace(with: .hardwarePairingFinish)
        }
    }
}

#Preview {
    OnboardingTabContainer()
}
