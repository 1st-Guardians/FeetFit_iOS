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

    #if DEBUG
    init(mockShoe: ShoeDetailInfo) {
        self.shoeId = mockShoe.id
        self.shoe = mockShoe
    }
    #endif


    func fetchDetail() {
        shoe = nil
        isLoading = true
        errorMessage = nil

        shoeProvider.request(.getShoeDetail(shoeId: shoeId)) { [weak self] result in
            guard let self else { return }

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
                            self.isLoading = false
                            self.errorMessage = decodedData.message
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }

                    guard let result = decodedData.result else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = "신발 상세 응답이 비어 있습니다."
                            ToastManager.shared.show("신발 상세 응답이 비어 있습니다.")
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.shoe = result.toDomain()
                    }

                } catch {
                    print("신발 상세 디코더 오류:", error)

                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "신발 상세 정보를 처리하지 못했습니다."
                        ToastManager.shared.show("신발 상세 정보를 처리하지 못했습니다.")
                    }
                }

            case .failure(let error):
                print("신발 상세 API 오류:", error)

                if let response = error.response {
                    print("신발 상세 API 실패 statusCode:", response.statusCode)

                    let errorResponse = try? JSONDecoder().decode(
                        APIErrorResponse.self,
                        from: response.data
                    )

                    let message = errorResponse?.message ?? "신발 상세 정보를 불러오지 못했습니다."

                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = message
                        ToastManager.shared.show(message)
                    }
                    return
                }

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "신발 상세 정보를 불러오지 못했습니다."
                    ToastManager.shared.show("신발 상세 정보를 불러오지 못했습니다.")
                }
            }
        }
    }
}
