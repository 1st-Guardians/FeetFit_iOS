//
//  SearchResultView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct SearchResultView: View {
    let shoes: [ShoeInfo]
    let onShoeTap: (ShoeInfo) -> Void
    
    private var hasResult: Bool {
        !shoes.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("검색 결과")
                .pretendardFont(.Title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 21)
                .padding(.horizontal, 20)
                .padding(.bottom, 17)
            
            if hasResult {
                ScrollView {
                    ShoeListView(
                        shoes: shoes,
                        onShoeTap: onShoeTap
                    )
                    .padding(.bottom, 70)
                }
            } else {
                Text("해당하는 검색 결과가 없습니다.")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}

#Preview {
    SearchResultView(
        shoes: [],
        onShoeTap: { _ in }
    )
}
