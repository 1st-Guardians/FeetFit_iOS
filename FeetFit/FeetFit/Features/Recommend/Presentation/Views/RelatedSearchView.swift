//
//  RelatedSearchView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct RelatedSearchView: View {
    let shoes: [ShoeInfo]
    
    private var hasResult: Bool {
        !shoes.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("연관 검색어")
                .pretendardFont(.Title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 21)
                .padding(.horizontal, 20)
                .padding(.bottom, 17)
            
            if hasResult {
                ScrollView {
                    ShoeListView(shoes: shoes)
                        .padding(.bottom, 70)
                }
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}

#Preview {
    RelatedSearchView(shoes: [])
}
