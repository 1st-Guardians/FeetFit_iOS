//
//  LoginView.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import SwiftUI


struct LoginView: View {
    let onFinish: () -> Void
    
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("FeetFit")
                .resizable()
                .frame(width: 159, height: 126)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 220)
            
            VStack(spacing: 14) {
                Button(action: {
                    viewModel.kakaoLogin()
                }) {
                    HStack(spacing: 5) {
                        Image(.kakaoLogo)
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Text("카카오 로그인")
                            .pretendardFont(.BlockTitle)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(.yellow02).interactive())
                .padding(.horizontal, 16)
                .onChange(of: viewModel.isLogin) { _, isLogin in
                    guard isLogin else { return }
                    
                    if viewModel.requiresProfileSetup {
                        print("사용자 정보 입력 화면으로 이동")
                    } else {
                        print("홈 화면으로 이동")
                    }
                }
                
                
                Button(action: {
                    print("애플 로그인")
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "apple.logo")
                            .pretendardFont(.BlockTitle)
                        
                        Text("Apple로 로그인")
                            .pretendardFont(.BlockTitle)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(.white).interactive())
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isLogin) { _, isLogin in
            guard isLogin else { return }
            
            if viewModel.requiresProfileSetup {
                router.replace(with: .onboardingUserInfo)
            } else {
                onFinish()
            }
        }
        
    }
}
