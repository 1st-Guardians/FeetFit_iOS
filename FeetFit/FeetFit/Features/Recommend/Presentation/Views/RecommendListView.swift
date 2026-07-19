//
//  RecommendListView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct RecommendListView: View {
    @ObservedObject var viewModel: RecommendListViewModel
    
    let onShoeTap: (ShoeInfo) -> Void
    
    @State private var searchText: String = ""
    @State private var searchMode: ShoeSearchMode = .list
    @State private var submittedSearchText: String = ""
    
    private var relatedShoes: [ShoeInfo] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            return []
        }
        
        return viewModel.shoes.filter {
            $0.brand.localizedCaseInsensitiveContains(keyword) ||
            $0.name.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    private var currentShoes: [ShoeInfo] {
        switch searchMode {
        case .list:
            return viewModel.shoes
            
        case .recent:
            return []
            
        case .related:
            return relatedShoes
            
        case .result:
            return viewModel.searchResults
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            
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
        .onAppear {
            viewModel.fetchInitialData()
        }
        .onChange(of: viewModel.selectedSortType) { _, _ in
            viewModel.reloadShoes()
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
        ZStack(alignment: .topLeading) {
            background
            
            VStack(alignment: .leading, spacing: 0) {
                topGroup
                    .padding([.bottom, .horizontal], 16)
                
                ScrollView {
                    ShoeListView(
                        shoes: viewModel.shoes,
                        onShoeTap: onShoeTap,
                        onShoeAppear: { shoe in
                            viewModel.loadNextPageIfNeeded(currentShoe: shoe)
                        }
                    )
                    .padding(.bottom, 70)
                }
            }
        }
    }
    
    private var background: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .blueLinear()
                .padding(.bottom, 502)
            
            Spacer()
        }
    }
    
    private var topGroup: some View {
        VStack(alignment: .leading) {
            Text("신발 추천")
                .pretendardFont(.Title)
                .padding(.top, 26)
                .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(viewModel.nickname.isEmpty ? "내" : "\(viewModel.nickname)님의") 발에 맞는 신발을 추천해드릴게요")
                    .pretendardFont(.BlockTitle)
                    .padding(.bottom, 10)
                
                Text(viewModel.footTypeText ?? "발 측정 결과를 기반으로 적합도, 별점, 관심도 순으로 신발을 확인할 수 있어요.")
                    .pretendardFont(.BlockText)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.35))
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue02)
                    .shadow(color: .blue02, radius: 2, x: 0, y: 0)
                    .mask {
                        Rectangle()
                            .padding(-8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                    }
            }
            .padding(.bottom, 18)
            
            HStack {
                Text("\(viewModel.totalElements)개")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                
                Spacer()
                
                ShoeSortMenuButton(selectedSortType: $viewModel.selectedSortType)
            }
        }
    }
    
    private func handleSearchTap() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if keyword.isEmpty {
            searchMode = .recent
            viewModel.fetchSearchHistory()
        } else {
            searchMode = .related
        }
    }
    
    private func handleSearchClear() {
        searchText = ""
        submittedSearchText = ""
        searchMode = .list
        viewModel.clearSearchResults()
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
            
            if searchMode != .list {
                searchMode = .recent
                viewModel.fetchSearchHistory()
            }
            return
        }
        
        if searchMode == .result {
            if keyword != submittedSearchText {
                searchMode = .related
            }
            return
        }
        
        if searchMode == .list || searchMode == .recent || searchMode == .related {
            searchMode = .related
        }
    }
}

#Preview {
    RecommendListView(
        viewModel: RecommendListViewModel(),
        onShoeTap: { _ in }
    )
}
