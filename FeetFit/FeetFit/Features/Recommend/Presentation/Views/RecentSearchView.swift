//
//  RecentSearchView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct RecentSearchView: View {
    let recentKeywords: [String]
    let onSelectKeyword: (String) -> Void
    let onDeleteKeyword: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("최근 검색 기록")
                .pretendardFont(.BlockTitle)
                .foregroundStyle(.gray01)
                .padding(.top, 21)
                .padding(.horizontal, 20)
                .padding(.bottom, 13)
            
            if recentKeywords.isEmpty {
                Text("최근 검색 기록이 없습니다.")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(recentKeywords, id: \.self) { keyword in
                            HStack(spacing: 8) {
                                Button {
                                    onDeleteKeyword(keyword)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray01)
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    onSelectKeyword(keyword)
                                } label: {
                                    Text(keyword)
                                        .pretendardFont(.BlockText)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}

#Preview {
    RecentSearchView(
        recentKeywords: ["나이키", "척테일러"],
        onSelectKeyword: { _ in },
        onDeleteKeyword: { _ in }
    )
}
