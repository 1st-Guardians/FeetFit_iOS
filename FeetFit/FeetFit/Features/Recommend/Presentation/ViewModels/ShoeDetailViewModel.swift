//
//  ShoeDetailViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation
import Combine
import Moya

final class ShoeDetailViewModel: ObservableObject {
    @Published var shoe: ShoeDetailInfo?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let shoeId: Int
    
    private let shoeProvider = APIManager.shared.createProvider(
        for: ShoeRoute.self,
        withAuth: true
    )
    
    init(shoeId: Int) {
        self.shoeId = shoeId
    }
    
    func fetchDetail() {
        isLoading = true
        errorMessage = nil
        
        shoeProvider.request(.getShoeDetail(shoeId: shoeId)) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    print("신발 상세 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeDetailResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.errorMessage = decodedData.message
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    guard let result = decodedData.result else {
                        DispatchQueue.main.async {
                            self.errorMessage = "신발 상세 응답이 비어 있습니다."
                            ToastManager.shared.show("신발 상세 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.shoe = result.toDomain()
                    }
                    
                } catch {
                    print("신발 상세 디코더 오류:", error)
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "신발 상세 정보를 처리하지 못했습니다."
                        ToastManager.shared.show("신발 상세 정보를 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("신발 상세 API 오류:", error)
                
                DispatchQueue.main.async {
                    self.errorMessage = "신발 상세 정보를 불러오지 못했습니다."
                    ToastManager.shared.show("신발 상세 정보를 불러오지 못했습니다.")
                }
            }
        }
    }
}
