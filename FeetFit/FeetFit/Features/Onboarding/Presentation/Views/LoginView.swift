//
//  LoginView.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import SwiftUI


struct LoginView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            Image("FeetFit")
                .resizable()
                .frame(width: 159, height: 126)
                .padding(.bottom, 270)
            
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
                    .background(.yellow02)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray02, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
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
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray02, lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }
            
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.isLogin) { _, isLogin in
            guard isLogin else { return }
            
            router.push(.onboardingUserInfo)
            
        }
        
    }
}


#Preview {
    LoginView()
}
