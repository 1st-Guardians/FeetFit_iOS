//
//  HardwarePairingViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Combine
import Moya

final class HardwarePairingViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var isConnected: Bool = false
    
    private let deviceProvider = APIManager.shared.createProvider(
        for: DeviceRouter.self,
        withAuth: true
    )
    
    func registerDevice() {
        let request = DeviceRegisterRequest(
            deviceName: "FeetFit-001",
            connectionType: .bluetooth
        )
        
        isLoading = true
        
        deviceProvider.request(.registerDevice(request: request)) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    print("디바이스 등록 statusCode:", response.statusCode)
                    print("디바이스 등록 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<DeviceResponse>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    guard let device = decodedData.result else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show("디바이스 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.isConnected = device.deviceConnected
                    }
                    
                } catch {
                    print("DeviceResponse 디코더 오류:", error)
                    print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    DispatchQueue.main.async {
                        ToastManager.shared.show("하드웨어 등록 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("Device Register API 오류:", error)
                
                DispatchQueue.main.async {
                    ToastManager.shared.show("하드웨어를 등록하지 못했습니다.")
                }
            }
        }
    }
    
    func deleteDevice() {
        isLoading = true
        
        deviceProvider.request(.deleteDevice) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<DeviceResponse>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.isConnected = false
                    }
                    
                } catch {
                    print("Device Delete 디코더 오류:", error)
                    print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                    
                    DispatchQueue.main.async {
                        ToastManager.shared.show("하드웨어 삭제 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("Device Delete API 오류:", error)
                
                DispatchQueue.main.async {
                    ToastManager.shared.show("하드웨어 연결을 해제하지 못했습니다.")
                }
            }
        }
    }
}
