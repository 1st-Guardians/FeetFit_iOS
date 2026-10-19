//
//  RecommendListView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct RecommendListView: View {
    @ObservedObject var viewModel: RecommendListViewModel
    @StateObject private var drugViewModel = DrugListViewModel()
    
    let onShoeTap: (ShoeInfo) -> Void
    var onProductTap: (ProductInfo) -> Void = { _ in }
    
    @State private var selectedRecommendation = "제품 추천"
    @State private var searchText: String = ""
    @State private var searchMode: ShoeSearchMode = .list
    @State private var submittedSearchText: String = ""
    
    private var currentShoes: [ShoeInfo] {
        switch searchMode {
        case .list:
            return viewModel.shoes
            
        case .recent:
            return []
            
        case .related:
            return viewModel.relatedSearchResults
            
        case .result:
            return viewModel.searchResults
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            
            if selectedRecommendation == "신발 추천" {
                SearchBarView(
                    text: $searchText,
                    placeholder: "신발을 검색해 보세요",
                    onTap: handleSearchTap,
                    onClear: handleSearchClear,
                    onSubmit: handleSearchSubmit
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            viewModel.fetchInitialData()
            drugViewModel.fetchInitialData()
        }
        .onChange(of: searchText) { _, newValue in
            handleSearchTextChange(newValue)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch searchMode {
        case .list:
            mainContent
            
        case .recent:
            RecentSearchView(
                histories: viewModel.recentSearchHistories,
                onSelectKeyword: { keyword in
                    submittedSearchText = keyword
                    searchText = keyword
                    searchMode = .result
                    viewModel.searchShoes(keyword: keyword, page: 0)
                },
                onDeleteHistory: { historyId in
                    viewModel.deleteSearchHistory(historyId: historyId)
                }
            )
            
        case .related:
            RelatedSearchView(
                shoes: currentShoes,
                onShoeTap: onShoeTap
            )
            
        case .result:
            SearchResultView(
                shoes: currentShoes,
                onShoeTap: onShoeTap
            )
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topGroup
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                if selectedRecommendation == "신발 추천" {
                    if viewModel.shoes.isEmpty && viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        ShoeListView(
                            shoes: viewModel.shoes,
                            onShoeTap: onShoeTap,
                            onShoeAppear: { shoe in
                                viewModel.loadNextPageIfNeeded(currentShoe: shoe)
                            }
                        )
                    }
                } else {
                    VStack(spacing: 16) {
                        ProductListView(
                            products: drugViewModel.products,
                            onProductTap: onProductTap,
                            onProductAppear: { drugViewModel.loadNextPageIfNeeded(currentProduct: $0) }
                        )

                        if drugViewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if let message = drugViewModel.errorMessage {
                            VStack(spacing: 12) {
                                Text(message)
                                    .pretendardFont(.BlockText)
                                Button("다시 시도") { drugViewModel.retry() }
                                    .tint(.blue01)
                            }
                            .padding()
                        } else if drugViewModel.products.isEmpty {
                            Text("추천 제품이 없습니다.")
                                .pretendardFont(.BlockText)
                                .foregroundStyle(.gray01)
                                .padding()
                        }
                    }
                }
            }
            .padding(.bottom, selectedRecommendation == "신발 추천" ? 70 : 0)
        }
    }

    private var topGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("추천")
                .pretendardFont(.Title)
                .padding(.top, 26)
                .padding(.leading, 12)

            Picker("추천 유형", selection: $selectedRecommendation) {
                Text("제품 추천").tag("제품 추천")
                Text("신발 추천").tag("신발 추천")
            }
            .pickerStyle(.segmented)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 10) {
                Text("\(viewModel.nickname.isEmpty ? "내" : "\(viewModel.nickname)님의") 발 타입")
                    .pretendardFont(.BlockTitle)

                Text(recommendationDescription)
                    .pretendardFont(.BlockText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Color(red: 240 / 255, green: 249 / 255, blue: 1),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Color(red: 203 / 255, green: 235 / 255, blue: 1), lineWidth: 1)
            }
            .padding(.top, 20)

            HStack {
                Text("\(selectedRecommendation == "신발 추천" ? viewModel.totalElements : drugViewModel.totalElements)개")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)

                Spacer()

                if selectedRecommendation == "신발 추천" {
                    ShoeSortMenuButton(
                        selectedSortType: Binding(
                            get: { viewModel.selectedSortType },
                            set: { viewModel.updateSortType($0) }
                        )
                    )
                } else {
                    Picker("제품 카테고리", selection: Binding(
                        get: { drugViewModel.selectedCategory },
                        set: { drugViewModel.updateCategory($0) }
                    )) {
                        ForEach(drugViewModel.orderedCategories) { category in
                            Text(category.label).tag(category)
                                .pretendardFont(.Description)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.black01)
                }
            }
            .padding(.top, 18)
        }
    }

    private var recommendationDescription: String {
        if selectedRecommendation == "제품 추천" {
            return drugViewModel.recommendationSummary
        }
        return viewModel.footTypeText ?? "발 측정 결과를 기반으로 적합도, 별점, 관심도 순으로 신발을 확인할 수 있어요."
    }

    private func handleSearchTap() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if keyword.isEmpty {
            searchMode = .recent
            viewModel.fetchSearchHistory()
        } else {
            searchMode = .related
            viewModel.searchShoeSuggestions(keyword: keyword, page: 0)
        }
    }
    
    private func handleSearchClear() {
        searchText = ""
        submittedSearchText = ""
        searchMode = .list
        viewModel.clearSearchResults()
        viewModel.clearRelatedSearchResults()
    }
    
    private func handleSearchSubmit() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            searchMode = .recent
            viewModel.fetchSearchHistory()
            return
        }
        
        submittedSearchText = keyword
        searchMode = .result
        viewModel.searchShoes(keyword: keyword, page: 0)
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        let keyword = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            submittedSearchText = ""
            viewModel.clearSearchResults()
            viewModel.clearRelatedSearchResults()
            
            if searchMode != .list {
                searchMode = .recent
                viewModel.fetchSearchHistory()
            }
            return
        }
        
        if searchMode == .result {
            if keyword != submittedSearchText {
                searchMode = .related
                viewModel.searchShoeSuggestions(keyword: keyword, page: 0)
            }
            return
        }
        
        if searchMode == .list || searchMode == .recent || searchMode == .related {
            searchMode = .related
            viewModel.searchShoeSuggestions(keyword: keyword, page: 0)
        }
    }
}

#Preview {
    RecommendListView(
        viewModel: RecommendListViewModel(),
        onShoeTap: { _ in }
    )
}
