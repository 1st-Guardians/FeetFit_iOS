//
//  OnboardingUserInfoViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Combine
import Moya

final class OnboardingUserInfoViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    
    private let userProvider = APIManager.shared.createProvider(
        for: UserRouter.self,
        withAuth: true
    )
    
    func setupProfile(
        userInfo: UserInfo,
        agreementState: AgreementState
    ) {
        guard let request = makeRequest(
            userInfo: userInfo,
            agreementState: agreementState
        ) else {
            ToastManager.shared.show("입력값을 다시 확인해주세요.")
            return
        }
        
        isLoading = true
        
        userProvider.request(.setupProfile(request: request)) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ProfileSetupResponse>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    guard let profile = decodedData.result else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show("사용자 정보 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    print("사용자 정보 등록 성공")
                    print("userId:", profile.userId)
                    print("requiresProfileSetup:", profile.requiresProfileSetup)
                    
                    DispatchQueue.main.async {
                        self.isSuccess = true
                    }
                    
                } catch {
                    print("ProfileSetupResponse 디코더 오류:", error)
                    print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    DispatchQueue.main.async {
                        ToastManager.shared.show("사용자 정보 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("Profile Setup API 오류:", error)
                
                if let response = error.response {
                    print("Profile Setup statusCode:", response.statusCode)
                    print("Profile Setup 에러 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                }
                
                DispatchQueue.main.async {
                    ToastManager.shared.show("사용자 정보를 저장하지 못했습니다.")
                }
            }
        }
    }
    
    private func makeRequest(
        userInfo: UserInfo,
        agreementState: AgreementState
    ) -> ProfileSetupRequest? {
        let nickname = userInfo.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !nickname.isEmpty,
              nickname.count <= 50,
              let age = Int(userInfo.age),
              (1...120).contains(age),
              let heightCm = Double(userInfo.height),
              (30.0...250.0).contains(heightCm),
              let weightKg = Double(userInfo.weight),
              (1.0...300.0).contains(weightKg),
              let footSize = Int(userInfo.footSize),
              (150...350).contains(footSize),
              let gender = userInfo.gender,
              agreementState.isRequiredChecked
        else {
            return nil
        }
        
        return ProfileSetupRequest(
            nickname: nickname,
            age: age,
            heightCm: heightCm,
            weightKg: weightKg,
            footSize: footSize,
            gender: gender.apiValue,
            termsAgreed: true
        )
    }
}
