import Foundation
import Combine
import Moya

@MainActor
final class DrugListViewModel: ObservableObject {
    @Published private(set) var products: [ProductInfo] = []
    @Published private(set) var selectedCategory: DrugCategory = .athletesFoot
    @Published private(set) var query = ""
    @Published private(set) var totalElements = 0
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasMeasurement: Bool?
    @Published private(set) var summary: String?
    @Published private(set) var orderedCategories = DrugCategory.allCases

    var recommendationSummary: String {
        if let summary, !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return summary
        }
        if hasMeasurement == false {
            return "발을 측정하면 측정 결과에 맞는 제품 정보를 안내해 드려요."
        }
        if hasMeasurement == true {
            return "측정 결과를 바탕으로 제품 추천 안내를 준비하고 있어요."
        }
        return isLoading ? "제품 추천 정보를 불러오는 중이에요." : "발 측정 결과를 바탕으로 제품 정보를 안내해 드려요."
    }

    private var currentPage = 0
    private var hasNext = false
    private var didApplyInitialPriority = false
    private var requestID = UUID()
    private var request: Moya.Cancellable?

    private let drugProvider = APIManager.shared.createProvider(
        for: DrugRoute.self,
        withAuth: true
    )

    func fetchInitialData() {
        fetchProducts()
    }

    func updateCategory(_ category: DrugCategory) {
        guard selectedCategory != category else { return }
        didApplyInitialPriority = true
        selectedCategory = category
        fetchProducts()
    }

    func search(query: String) {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard self.query != keyword else { return }
        didApplyInitialPriority = true
        self.query = keyword
        fetchProducts()
    }

    func loadNextPageIfNeeded(currentProduct: ProductInfo) {
        guard !isLoading, errorMessage == nil, hasNext,
              currentProduct.id == products.last?.id else { return }
        fetchProducts(page: currentPage + 1)
    }

    func retry() {
        guard !isLoading else { return }
        fetchProducts(page: products.isEmpty ? 0 : currentPage + 1)
    }

    private func fetchProducts(page: Int = 0) {
        let id = UUID()
        requestID = id
        request?.cancel()
        isLoading = true
        errorMessage = nil

        if page == 0 {
            products = []
            totalElements = 0
            currentPage = 0
            hasNext = false
        }

        request = drugProvider.request(
            .getDrugs(category: selectedCategory, query: query, page: page, size: 20)
        ) { [weak self] response in
            DispatchQueue.main.async {
                guard let self, self.requestID == id else { return }
                defer {
                    if self.requestID == id { self.isLoading = false }
                }

                switch response {
                case .success(let response):
                    do {
                        let decoded = try JSONDecoder().decode(BaseResponse<DrugListResultDTO>.self, from: response.data)
                        guard decoded.isSuccess else {
                            throw APIError.serverError(decoded.message)
                        }
                        guard let result = decoded.result else {
                            throw APIError.serverError("제품 목록 응답이 비어 있습니다.")
                        }

                        if page == 0 {
                            self.hasMeasurement = result.hasMeasurement
                            self.summary = result.summary
                            self.orderedCategories = result.orderedCategories

                            if !self.didApplyInitialPriority {
                                self.didApplyInitialPriority = true
                                if let category = self.orderedCategories.first, category != self.selectedCategory {
                                    self.selectedCategory = category
                                    self.fetchProducts()
                                    return
                                }
                            }
                        }

                        let products = result.items.map {
                            $0.toDomain(categoryLabel: result.categoryLabel ?? self.selectedCategory.label, source: result.source)
                        }
                        let grouped = Dictionary(grouping: page == 0 ? products : self.products + products, by: \.category)
                        self.products = self.orderedCategories.flatMap { grouped[$0] ?? [] } + (grouped[nil] ?? [])
                        self.currentPage = result.currentPage
                        self.hasNext = result.hasNext
                        self.totalElements = result.totalElements
                    } catch {
                        self.showError((error as? APIError)?.errorDescription ?? "제품 목록을 처리하지 못했습니다.")
                    }

                case .failure(let error):
                    let errorResponse = error.response.flatMap {
                        try? JSONDecoder().decode(APIErrorResponse.self, from: $0.data)
                    }
                    self.showError(errorResponse?.message ?? "제품 목록을 불러오지 못했습니다.")
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        ToastManager.shared.show(message)
    }
}
