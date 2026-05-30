//
//  MyPageViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation
import Combine
import Moya

final class MyPageViewModel: ObservableObject {
    @Published var userInfo = UserInfo()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var requiresProfileSetup: Bool = false
    
    private let myPageProvider = APIManager.shared.createProvider(
        for: MyPageRouter.self,
        withAuth: true
    )
    
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        myPageProvider.request(.getProfile) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    print("프로필 조회 statusCode:", response.statusCode)
                    print("프로필 조회 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<MyPageProfileResult>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.errorMessage = decodedData.message
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    guard let profile = decodedData.result else {
                        DispatchQueue.main.async {
                            self.errorMessage = "프로필 응답이 비어 있습니다."
                            ToastManager.shared.show("프로필 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.userInfo = UserInfo(
                            nickname: profile.nickname,
                            age: String(profile.age),
                            weight: String(profile.weightKg),
                            height: String(profile.heightCm),
                            footSize: String(profile.footSize),
                            gender: profile.gender
                        )
                        
                        self.requiresProfileSetup = profile.requiresProfileSetup
                    }
                    
                } catch {
                    print("프로필 디코더 오류:", error)
                    print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "프로필 정보를 처리하지 못했습니다."
                        ToastManager.shared.show("프로필 정보를 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("프로필 조회 API 오류:", error)
                
                DispatchQueue.main.async {
                    self.errorMessage = "프로필 정보를 불러오지 못했습니다."
                    ToastManager.shared.show("프로필 정보를 불러오지 못했습니다.")
                }
            }
        }
    }
}
