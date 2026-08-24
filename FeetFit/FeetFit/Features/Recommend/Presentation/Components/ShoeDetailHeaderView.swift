//
//  ShoeDetailHeaderView.swift
//  FeetFit
//

import SwiftUI

struct ShoeDetailHeaderView: View {
    let shoe: ShoeDetailInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shoe.brand)
                .pretendardFont(.BlockText)

            Text(shoe.name)
                .pretendardFont(.SubTitle)

            ratingSection
                .padding(.vertical, 8)

            Text(shoe.formattedPrice)
                .pretendardFont(.Title)
        }
        .foregroundStyle(.black01)
        .padding(.horizontal, 8)
        .padding(.top, 24)
    }

    private var ratingSection: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starName(for: index))
                    .font(.system(size: 25))
                    .foregroundStyle(.yellow)
            }

            TooltipButton(message:
                """
                외부 사이트에서 수집한 실제 사용자 리뷰 별점을 기반으로 계산한 평균 평점이에요. 전체적인 평가를 보여주는 값이며, 개인별 착화감과는 차이가 있을 수 있어요.
                """
            )
            .foregroundStyle(.black01)
            .padding([.top, .leading], 5)
        }
    }

    private func starName(for index: Int) -> String {
        let fullStarCount = Int(shoe.rating)
        let hasHalfStar = shoe.rating - Double(fullStarCount) >= 0.5

        if index < fullStarCount {
            return "star.fill"
        } else if index == fullStarCount && hasHalfStar {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    ShoeDetailHeaderView(shoe: .mock)
        .padding()
}
