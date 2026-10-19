//
//  LoginViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//
import Combine
import Foundation
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser
import Moya

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var requiresProfileSetup: Bool = false
    @Published private(set) var isLoggingIn = false
    
    private let authProvider = APIManager.shared.createProvider(
        for: AuthRouter.self,
        withAuth: false
    )

    
    func kakaoLogin() {
        guard !isLoggingIn, !isLogin else { return }
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
            
            self.requestLogin(.postKakao(accessToken: kakaoAccessToken))
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
            
            self.requestLogin(.postKakao(accessToken: kakaoAccessToken))
        }
    }
    
    func handleAppleAuthorization(_ result: Result<ASAuthorization, Error>) {
        guard !isLoggingIn, !isLogin else { return }

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let data = credential.authorizationCode,
                  let code = String(data: data, encoding: .utf8),
                  !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                #if DEBUG
                print("[AppleLogin] 유효한 인증 코드를 받지 못함")
                #endif
                ToastManager.shared.show("애플 인증 코드를 가져오지 못했습니다. 다시 시도해 주세요.")
                return
            }

            requestLogin(.postApple(code: code))

        case .failure(let error):
            #if DEBUG
            let authError = error as NSError
            print("[AppleLogin] 인증 종료: domain=\(authError.domain), code=\(authError.code)")
            #endif
            guard (error as? ASAuthorizationError)?.code != .canceled else { return }
            ToastManager.shared.show("애플 로그인에 실패했습니다. 다시 시도해 주세요.")
        }
    }

    private func requestLogin(_ route: AuthRouter) {
        guard !isLoggingIn, !isLogin else { return }
        isLoggingIn = true

        #if DEBUG
        print("[Login] POST \(route.path) 요청 시작")
        #endif
        authProvider.request(route) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                defer { self.isLoggingIn = false }

                switch result {
                case .success(let response):
                    do {
                        let decodedData = try JSONDecoder().decode(
                            BaseResponse<LoginResponse>.self,
                            from: response.data
                        )

                        #if DEBUG
                        print("[Login] \(route.path) HTTP=\(response.statusCode), code=\(decodedData.code), isSuccess=\(decodedData.isSuccess)")
                        #endif
                        guard decodedData.isSuccess else {
                            ToastManager.shared.show(decodedData.message)
                            return
                        }

                        guard let loginResult = decodedData.result else {
                            ToastManager.shared.show("로그인 응답이 비어 있습니다.")
                            return
                        }

                        guard !loginResult.accessToken.isEmpty, !loginResult.refreshToken.isEmpty else {
                            ToastManager.shared.show("로그인 응답을 처리하지 못했습니다.")
                            return
                        }

                        TokenManager.shared.save(
                            accessToken: loginResult.accessToken,
                            refreshToken: loginResult.refreshToken
                        )
                        self.requiresProfileSetup = loginResult.requiresProfileSetup
                        self.isLogin = true

                        #if DEBUG
                        print("[Login] 로그인 완료: requiresProfileSetup=\(loginResult.requiresProfileSetup)")
                        #endif

                    } catch {
                        #if DEBUG
                        print("[Login] \(route.path) HTTP=\(response.statusCode), 로그인 응답 디코딩 실패")
                        #endif
                        ToastManager.shared.show("로그인 응답을 처리하지 못했습니다.")
                    }

                case .failure(let error):
                    let errorResponse = error.response.flatMap {
                        try? JSONDecoder().decode(APIErrorResponse.self, from: $0.data)
                    }
                    #if DEBUG
                    print("[Login] \(route.path) 요청 실패: HTTP=\(error.response?.statusCode.description ?? "응답 없음"), code=\(errorResponse?.code ?? "없음")")
                    if error.response == nil, case .underlying(let underlyingError, _) = error {
                        let networkError = underlyingError as NSError
                        print("[Login] 네트워크 오류: domain=\(networkError.domain), code=\(networkError.code)")
                    }
                    #endif
                    let fallbackMessage: String
                    if let statusCode = error.response?.statusCode, (500...599).contains(statusCode) {
                        fallbackMessage = "로그인 서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요."
                    } else {
                        fallbackMessage = "로그인에 실패했습니다. 다시 시도해 주세요."
                    }
                    ToastManager.shared.show(errorResponse?.message ?? fallbackMessage)
                }
            }
        }
    }
}
