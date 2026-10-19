//
//  LoginView.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import SwiftUI
import AuthenticationServices


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

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { _ in
                        #if DEBUG
                        print("[AppleLogin] Apple 인증 요청 시작")
                        #endif
                    },
                    onCompletion: viewModel.handleAppleAuthorization
                )
                .signInWithAppleButtonStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .clipShape(Capsule())
                .glassEffect(.regular.tint(.white).interactive())
                .padding(.horizontal, 16)
            }
            .disabled(viewModel.isLoggingIn)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isLogin) { _, isLogin in
            guard isLogin else { return }

            #if DEBUG
            print("[Login] 화면 이동: \(viewModel.requiresProfileSetup ? "프로필 등록" : "메인")")
            #endif
            
            if viewModel.requiresProfileSetup {
                router.replace(with: .onboardingUserInfo)
            } else {
                onFinish()
            }
        }
        
    }
}
