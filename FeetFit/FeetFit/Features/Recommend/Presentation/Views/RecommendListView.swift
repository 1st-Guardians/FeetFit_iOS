//
//  RecommendListView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct RecommendListView: View {
    @State private var selectedSortType: ShoeSortType = .fit
    @State private var searchText: String = ""
    @State private var searchMode: ShoeSearchMode = .list
    @State private var submittedSearchText: String = ""
    
    private let recommendation: ShoeRecommendation = .mock
    @State private var recentKeywords: [String] = ["나이키", "척테일러"]
    
    private var filteredShoes: [ShoeInfo] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            return recommendation.shoes
        }
        
        return recommendation.shoes.filter {
            $0.brand.localizedCaseInsensitiveContains(keyword) ||
            $0.name.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    private var sortedShoes: [ShoeInfo] {
        selectedSortType.sort(filteredShoes)
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
                recentKeywords: recentKeywords,
                onSelectKeyword: { keyword in
                    submittedSearchText = keyword
                    searchText = keyword
                    searchMode = .result
                },
                onDeleteKeyword: { keyword in
                    recentKeywords.removeAll { $0 == keyword }
                }
            )
            
        case .related:
            RelatedSearchView(shoes: sortedShoes)
            
        case .result:
            SearchResultView(shoes: sortedShoes)
        }
    }
    
    private var mainContent: some View {
        ZStack(alignment: .topLeading) {
            background
            
            VStack(alignment: .leading, spacing: 0) {
                topGroup
                    .padding([.bottom, .horizontal], 16)
                ScrollView {
                    ShoeListView(shoes: sortedShoes)
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
                Text("\(recommendation.userName)님의 발 타입은요..")
                    .pretendardFont(.BlockTitle)
                    .padding(.bottom, 10)
                
                Text(recommendation.footDescription)
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
                Text("\(sortedShoes.count)개")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                
                Spacer()
                
                ShoeSortMenuButton(selectedSortType: $selectedSortType)
            }
        }
    }
    
    private func handleSearchTap() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if keyword.isEmpty {
            searchMode = .recent
        } else {
            searchMode = .related
        }
    }
    
    private func handleSearchClear() {
        searchText = ""
        searchMode = .list
    }
    
    private func handleSearchSubmit() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            searchMode = .recent
            return
        }
        
        submittedSearchText = keyword
        searchMode = .result
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        let keyword = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !keyword.isEmpty else {
            submittedSearchText = ""
            
            if searchMode != .list {
                searchMode = .recent
            }
            return
        }
        
        if searchMode == .result {
            if keyword != submittedSearchText {
                searchMode = .related
            }
            return
        }
        
        if searchMode == .list || searchMode == .recent {
            searchMode = .related
        }
    }
}

#Preview {
    RecommendListView()
}
