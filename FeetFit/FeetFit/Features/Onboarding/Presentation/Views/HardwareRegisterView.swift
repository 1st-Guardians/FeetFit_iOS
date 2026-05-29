//
//  HardwareRegisterView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//
import SwiftUI
import Lottie

struct HardwareRegisterView: View {
    let onFinish: () -> Void
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    
    var body: some View {
        VStack(spacing: 0){
            
            LoadingMessageView(
                message: "하드웨어를\n등록해주세요."
            )
            .padding(.bottom, 277)
            
            
            
            MainButton("하드웨어 등록하기", action: {
                router.push(.hardwarePairing)
            })
            .padding(.bottom, 20)
            .padding(.horizontal, 18)
            
            Button {
                onFinish()
            } label: {
                Text("다음에 등록할래요")
                    .underline()
                    .pretendardFont(.Placeholder)
                    .foregroundStyle(.gray01)
            }
            .buttonStyle(.plain)
            
            
            
        }
        .navigationBarBackButtonHidden()
    }
}
