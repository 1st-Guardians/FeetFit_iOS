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

    // /api/shoes/{shoeId}/characteristics 결과 (신발 자체의 객관적 특성)
    @Published var specProfile: ShoeSpecProfile?
    @Published var featureComparisons: [ShoeFeatureComparison] = []

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
        self.specProfile = .mock
        self.featureComparisons = ShoeFeatureComparison.samples
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

    // 상품정보 탭 전용 보조 데이터라, 실패해도 로그만 남기고 메인 상세 화면은 막지 않는다.
    func fetchCharacteristics() {
        shoeProvider.request(.getShoeCharacteristics(shoeId: shoeId)) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let response):
                do {
                    print("신발 특성 조회 statusCode:", response.statusCode)

                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeCharacteristicsResultDTO>.self,
                        from: response.data
                    )

                    guard decodedData.isSuccess else {
                        print("신발 특성 조회 실패:", decodedData.message)
                        return
                    }

                    guard let result = decodedData.result else { return }

                    DispatchQueue.main.async {
                        self.specProfile = result.toSpecProfile()
                        self.featureComparisons = result.toFeatureComparisons()
                    }
                } catch {
                    print("신발 특성 디코더 오류:", error)
                }

            case .failure(let error):
                print("신발 특성 API 오류:", error)
            }
        }
    }
}
