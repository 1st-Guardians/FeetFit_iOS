//
//  RecommendListViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation
import Combine
import Moya

final class RecommendListViewModel: ObservableObject {
    @Published var shoes: [ShoeInfo] = []
    @Published var searchResults: [ShoeInfo] = []
    @Published var relatedSearchResults: [ShoeInfo] = []
    @Published var recentSearchHistories: [ShoeSearchHistoryDTO] = []
    
    @Published var topRecommendedShoes: [ShoeInfo] = []
    @Published var footTypeText: String?
    @Published var nickname: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedSortType: ShoeSortType = .fit
    
    private var currentPage: Int = 0
    private var hasNext: Bool = false
    
    private var searchCurrentPage: Int = 0
    private var searchHasNext: Bool = false
    
    private var relatedSearchCurrentPage: Int = 0
    private var relatedSearchHasNext: Bool = false
    private var latestSuggestionKeyword: String = ""
    
    private let shoeProvider = APIManager.shared.createProvider(
        for: ShoeRoute.self,
        withAuth: true
    )
    
    func fetchInitialData() {
        fetchFootTypeText()
        fetchTopRecommendations()
        fetchShoes(page: 0)
        fetchSearchHistory()
    }
    
    func fetchShoes(page: Int = 0) {
        isLoading = true
        errorMessage = nil
        
        shoeProvider.request(
            .getShoes(
                sort: selectedSortType,
                page: page,
                size: 20
            )
        ) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            switch result {
            case .success(let response):
                do {
                    print("신발 목록 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeListResultDTO>.self,
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
                            self.errorMessage = "신발 목록 응답이 비어 있습니다."
                            ToastManager.shared.show("신발 목록 응답이 비어 있습니다.")
                        }
                        return
                    }
                    
                    let mappedShoes = result.shoes.map { $0.toDomain() }
                    
                    DispatchQueue.main.async {
                        if page == 0 {
                            self.shoes = mappedShoes
                        } else {
                            self.shoes += mappedShoes
                        }
                        
                        self.currentPage = result.currentPage
                        self.hasNext = result.hasNext
                    }
                    
                } catch {
                    print("신발 목록 디코더 오류:", error)
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "신발 목록을 처리하지 못했습니다."
                        ToastManager.shared.show("신발 목록을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("신발 목록 API 오류:", error)
                
                DispatchQueue.main.async {
                    self.errorMessage = "신발 목록을 불러오지 못했습니다."
                    ToastManager.shared.show("신발 목록을 불러오지 못했습니다.")
                }
            }
        }
    }
    
    func reloadShoes() {
        fetchShoes(page: 0)
    }
    
    func loadNextPageIfNeeded(currentShoe: ShoeInfo) {
        guard !isLoading else { return }
        guard hasNext else { return }
        guard currentShoe.id == shoes.last?.id else { return }
        
        fetchShoes(page: currentPage + 1)
    }
    
    func fetchTopRecommendations() {
        shoeProvider.request(.getTopRecommendations) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("TOP3 추천 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeRecommendationResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.errorMessage = decodedData.message
                        }
                        return
                    }
                    
                    guard let result = decodedData.result else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.topRecommendedShoes = result.shoes.map { $0.toDomain() }
                    }
                    
                } catch {
                    print("TOP3 추천 디코더 오류:", error)
                }
                
            case .failure(let error):
                print("TOP3 추천 API 오류:", error)
            }
        }
    }
    
    func searchShoes(keyword: String, page: Int = 0) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else {
            clearSearchResults()
            return
        }
        
        shoeProvider.request(
            .searchShoes(
                keyword: trimmedKeyword,
                page: page,
                size: 20
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("신발 검색 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeSearchResultDTO>.self,
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
                        return
                    }
                    
                    let mappedShoes = result.results.map { $0.toDomain() }
                    
                    DispatchQueue.main.async {
                        if page == 0 {
                            self.searchResults = mappedShoes
                        } else {
                            self.searchResults += mappedShoes
                        }
                        
                        self.searchCurrentPage = result.currentPage
                        self.searchHasNext = result.hasNext
                    }
                    
                } catch {
                    print("신발 검색 디코더 오류:", error)
                }
                
            case .failure(let error):
                print("신발 검색 API 오류:", error)
            }
        }
    }
    
    func searchShoeSuggestions(keyword: String, page: Int = 0) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKeyword.isEmpty else {
            clearRelatedSearchResults()
            return
        }
        
        latestSuggestionKeyword = trimmedKeyword
        
        shoeProvider.request(
            .searchShoeSuggestions(
                keyword: trimmedKeyword,
                page: page,
                size: 20
            )
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("연관 검색어 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeSearchResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.errorMessage = decodedData.message
                        }
                        return
                    }
                    
                    guard let result = decodedData.result else {
                        return
                    }
                    
                    let mappedShoes = result.results.map { $0.toDomain() }
                    
                    DispatchQueue.main.async {
                        guard self.latestSuggestionKeyword == trimmedKeyword else {
                            return
                        }
                        
                        if page == 0 {
                            self.relatedSearchResults = mappedShoes
                        } else {
                            self.relatedSearchResults += mappedShoes
                        }
                        
                        self.relatedSearchCurrentPage = result.currentPage
                        self.relatedSearchHasNext = result.hasNext
                    }
                    
                } catch {
                    print("연관 검색어 디코더 오류:", error)
                }
                
            case .failure(let error):
                print("연관 검색어 API 오류:", error)
            }
        }
    }
    
    func fetchSearchHistory() {
        shoeProvider.request(.getSearchHistory) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("검색 기록 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<ShoeSearchHistoryResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        return
                    }
                    
                    guard let result = decodedData.result else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.recentSearchHistories = result.histories
                    }
                    
                } catch {
                    print("검색 기록 디코더 오류:", error)
                }
                
            case .failure(let error):
                print("검색 기록 API 오류:", error)
            }
        }
    }
    
    func deleteSearchHistory(historyId: Int) {
        shoeProvider.request(.deleteSearchHistory(historyId: historyId)) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("검색 기록 삭제 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<EmptyResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        DispatchQueue.main.async {
                            self.errorMessage = decodedData.message
                            ToastManager.shared.show(decodedData.message)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.recentSearchHistories.removeAll { $0.id == historyId }
                    }
                    
                } catch {
                    print("검색 기록 삭제 디코더 오류:", error)
                    
                    DispatchQueue.main.async {
                        self.errorMessage = "검색 기록 삭제 응답을 처리하지 못했습니다."
                        ToastManager.shared.show("검색 기록 삭제 응답을 처리하지 못했습니다.")
                    }
                }
                
            case .failure(let error):
                print("검색 기록 삭제 API 오류:", error)
                
                DispatchQueue.main.async {
                    self.errorMessage = "검색 기록을 삭제하지 못했습니다."
                    ToastManager.shared.show("검색 기록을 삭제하지 못했습니다.")
                }
            }
        }
    }
    
    func clearSearchResults() {
        searchResults = []
        searchCurrentPage = 0
        searchHasNext = false
    }
    
    func clearRelatedSearchResults() {
        relatedSearchResults = []
        relatedSearchCurrentPage = 0
        relatedSearchHasNext = false
        latestSuggestionKeyword = ""
    }
    
    func fetchFootTypeText() {
        shoeProvider.request(.getFootTypeText) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                do {
                    print("발 타입 문구 조회 statusCode:", response.statusCode)
                    
                    let decodedData = try JSONDecoder().decode(
                        BaseResponse<FootTypeTextResultDTO>.self,
                        from: response.data
                    )
                    
                    guard decodedData.isSuccess else {
                        return
                    }
                    
                    guard let result = decodedData.result else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.nickname = result.nickname
                        self.footTypeText = result.typeText
                    }
                    
                } catch {
                    print("발 타입 문구 디코더 오류:", error)
                }
                
            case .failure(let error):
                print("발 타입 문구 API 오류:", error)
            }
        }
    }
    
    func registerShoeClick(shoeId: Int) {
        shoeProvider.request(.registerClick(shoeId: shoeId)) { result in
            switch result {
            case .success(let response):
                print("신발 클릭 등록 statusCode:", response.statusCode)
                
            case .failure(let error):
                print("신발 클릭 등록 API 오류:", error)
            }
        }
    }
}
