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
    @Published var hardwareStatus: HardwareStatus = .unconnected
    @Published var hasMeasurementRecord: Bool = false
    
    private let myPageProvider = APIManager.shared.createProvider(
        for: MyPageRouter.self,
        withAuth: true
    )

    private let deviceProvider = APIManager.shared.createProvider(
        for: DeviceRouter.self,
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
                            weight: self.formatDouble(profile.weightKg),
                            height: self.formatDouble(profile.heightCm),
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

    func fetchDeviceStatus() {
        deviceProvider.request(.getDevice) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    print("하드웨어 연결 상태 statusCode:", response.statusCode)

                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<DeviceResponse>.self,
                        from: response.data
                    )

                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.hardwareStatus = .unconnected
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.hardwareStatus = decodedData.result?.deviceConnected == true ? .connected : .unconnected
                    }
                } catch {
                    print("하드웨어 연결 상태 디코더 오류:", error)
                    print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")

                    DispatchQueue.main.async {
                        self.hardwareStatus = .unconnected
                    }
                }

            case .failure(let error):
                print("하드웨어 연결 상태 API 오류:", error)

                DispatchQueue.main.async {
                    self.hardwareStatus = .unconnected
                }
            }
        }
    }

    func fetchMeasurementRecordStatus() {
        _Concurrency.Task {
            do {
                let weeklyStatus = try await MeasurementAPI.shared.fetchWeeklyStatus()

                await MainActor.run {
                    self.hasMeasurementRecord = weeklyStatus.hasWeeklyMeasurement
                }
            } catch {
                print("마이페이지 측정 기록 조회 API 오류:", error)
            }
        }
    }
    
    func updateProfile(
        nickname: String,
        age: String,
        height: String,
        weight: String,
        footSize: String,
        gender: Gender?,
        onSuccess: (() -> Void)? = nil
    ) {
        guard let ageValue = Int(age),
              let heightValue = Double(height),
              let weightValue = Double(weight),
              let footSizeValue = Int(footSize),
              let gender else {
            ToastManager.shared.show("입력값을 확인해주세요.")
            return
        }
        
        let request = MyPageProfileUpdateRequest(
            nickname: nickname,
            age: ageValue,
            heightCm: heightValue,
            weightKg: weightValue,
            footSize: footSizeValue,
            gender: gender
        )
        
        isLoading = true
        errorMessage = nil
        
        myPageProvider.request(.updateProfile(request: request)) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    print("프로필 수정 statusCode:", response.statusCode)
                    
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
                            self.errorMessage = "프로필 수정 응답이 비어 있습니다."
                            ToastManager.shared.show("프로필 수정 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.userInfo = UserInfo(
                            nickname: profile.nickname,
                            age: String(profile.age),
                            weight: self.formatDouble(profile.weightKg),
                            height: self.formatDouble(profile.heightCm),
                            footSize: String(profile.footSize),
                            gender: profile.gender
                        )
                        
                        self.requiresProfileSetup = profile.requiresProfileSetup
                        ToastManager.shared.show("프로필이 수정되었습니다.")
                        onSuccess?()
                    }
                    
                } catch {
                    print("프로필 수정 디코더 오류:", error)
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "프로필 수정 응답을 처리하지 못했습니다."
                        ToastManager.shared.show("프로필 수정 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("프로필 수정 API 오류:", error)
                
                DispatchQueue.main.async {
                    self.errorMessage = "프로필을 수정하지 못했습니다."
                    ToastManager.shared.show("프로필을 수정하지 못했습니다.")
                }
            }
        }
    }
    
    private func formatDouble(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(value))
        }
        
        return String(format: "%.1f", value)
    }
}
