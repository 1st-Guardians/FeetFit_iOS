import Foundation
import Combine
import Moya

@MainActor
final class DrugDetailViewModel: ObservableObject {
    @Published private(set) var product: ProductInfo
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var didLoadDetail = false
    private let drugProvider = APIManager.shared.createProvider(
        for: DrugRoute.self,
        withAuth: true
    )

    init(product: ProductInfo) {
        self.product = product
    }

    func fetchDetail() {
        guard !isLoading, !didLoadDetail, let itemSeq = product.itemSeq else { return }
        isLoading = true
        errorMessage = nil

        drugProvider.request(.getDrugPermit(itemSeq: itemSeq)) { [weak self] response in
            DispatchQueue.main.async {
                guard let self else { return }
                defer { self.isLoading = false }

                switch response {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(BaseResponse<DrugDetailResultDTO>.self, from: response.data)
                        guard decoded.isSuccess else {
                            throw APIError.serverError(decoded.message)
                        }
                        guard let result = decoded.result else {
                            throw APIError.serverError("약 상세 응답이 비어 있습니다.")
                        }

                        self.product = result.toDomain(categoryLabel: self.product.tag)
                        self.didLoadDetail = true
                    } catch {
                        self.showError((error as? APIError)?.errorDescription ?? "약 상세 정보를 처리하지 못했습니다.")
                    }

                case .failure(let error):
                    let errorResponse = error.response.flatMap {
                        try? JSONDecoder().decode(APIErrorResponse.self, from: $0.data)
                    }
                    self.showError(errorResponse?.message ?? "약 상세 정보를 불러오지 못했습니다.")
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        ToastManager.shared.show(message)
    }
}
