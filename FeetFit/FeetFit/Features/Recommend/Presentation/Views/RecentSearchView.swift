//
//  RecentSearchView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//[

import SwiftUI

struct RecentSearchView: View {
    let histories: [ShoeSearchHistoryDTO]
    let onSelectKeyword: (String) -> Void
    let onDeleteHistory: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("최근 검색 기록")
                .pretendardFont(.BlockTitle)
                .foregroundStyle(.gray01)
                .padding(.top, 21)
                .padding(.horizontal, 20)
                .padding(.bottom, 13)
            
            if histories.isEmpty {
                Text("최근 검색 기록이 없습니다.")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(histories) { history in
                            HStack(spacing: 8) {
                                Button {
                                    onDeleteHistory(history.id)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray01)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    onSelectKeyword(history.keyword)
                                } label: {
                                    Text(history.keyword)
                                        .pretendardFont(.BlockText)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
    }
}

#Preview {
    RecentSearchView(
        histories: [
            ShoeSearchHistoryDTO(id: 1, keyword: "나이키"),
            ShoeSearchHistoryDTO(id: 2, keyword: "척테일러")
        ],
        onSelectKeyword: { _ in },
        onDeleteHistory: { _ in }
    )
}
