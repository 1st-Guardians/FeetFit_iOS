//
//  TodayShoesRecommendView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct TodayShoesRecommendView: View {
    private var shoesList: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("오늘의 측정 결과로 신발 추천 받기")
                    .pretendardFont(.BlockTitle)
                Spacer()
                
                if !shoesList.isEmpty {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 8)
            
            if !shoesList.isEmpty {
                listView
            } else {
                emptyView
            }
        }
    }
    
    // MARK: - SubView
    private var emptyView: some View {
        VStack(spacing: 10) {
            Text("아직 발 상태를 측정하지 않았어요")
                .pretendardFont(.Description)
            Text("오늘 측정한 결과를 바탕으로\n내 발 건강 상태에 적합한 신발을 추천 받을 수 있어요")
                .pretendardFont(.BlockText)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .mainBoxStyle()
    }
    
    private var listView: some View {
        VStack {
            // TODO: 신발 리스트
        }
    }
}

#Preview {
    TodayShoesRecommendView()
}
