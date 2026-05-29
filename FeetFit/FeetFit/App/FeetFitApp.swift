//
//  FeetFitApp.swift
//  FeetFit
//
//  Created by 김미주 on 4/6/26.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct FeetFitApp: App {
    
    init() {
        let kakaoNativeAppKey = (Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String) ?? ""
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    
    
    var body: some Scene {
        WindowGroup {
            OnboardingTabContainer()
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
