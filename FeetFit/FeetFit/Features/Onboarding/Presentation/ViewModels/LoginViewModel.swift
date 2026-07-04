//
//  LoginViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//
import Combine
import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import Moya

class LoginViewModel: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var requiresProfileSetup: Bool = false
    
    private let authProvider = APIManager.shared.createProvider(
        for: AuthRouter.self,
        withAuth: false
    )

    
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            loginWithKakaoTalk()
        } else {
            loginWithKakaoAccount()
        }
    }
    
    private func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
            guard let self else { return }
            
            if let error {
                print("카카오톡 로그인 오류: \(error)")
                return
            }
            
            guard let kakaoAccessToken = oauthToken?.accessToken else {
                print("카카오톡 accessToken이 없습니다.")
                return
            }
            
            self.requestKakaoLogin(accessToken: kakaoAccessToken)
        }
    }
    
    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
            guard let self else { return }
            
            if let error {
                print("카카오계정 로그인 오류: \(error)")
                return
            }
            
            guard let kakaoAccessToken = oauthToken?.accessToken else {
                print("카카오계정 accessToken이 없습니다.")
                return
            }
            
            self.requestKakaoLogin(accessToken: kakaoAccessToken)
        }
    }
    
    private func requestKakaoLogin(accessToken: String) {
        authProvider.request(.postKakao(accessToken: accessToken)) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<KakaoLoginResponse>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    guard let loginResult = decodedData.result else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show("로그인 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    TokenManager.shared.save(
                        accessToken: loginResult.accessToken,
                        refreshToken: loginResult.refreshToken
                    )
                    
                    DispatchQueue.main.async {
                        self.requiresProfileSetup = loginResult.requiresProfileSetup
                        self.isLogin = true
                    }
                    
                    print("카카오 로그인 성공")
                    print(loginResult.accessToken)
                    print("프로필 설정 필요 여부: \(loginResult.requiresProfileSetup)")
                    
                } catch {
                    print("KakaoLoginResponse 디코더 오류: \(error)")
                    
                    DispatchQueue.main.async {
                        ToastManager.shared.show("로그인 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("Kakao Login API 오류: \(error)")
                
                DispatchQueue.main.async {
                    ToastManager.shared.show("카카오 로그인에 실패했습니다.")
                }
            }
        }
    }
}
