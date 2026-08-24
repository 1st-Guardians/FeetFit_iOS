//
//  ShoeFitSummarySection.swift
//  FeetFit
//

import SwiftUI

struct ShoeFitSummarySection: View {
    let shoe: ShoeDetailInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("한 눈에 보는 착용 포인트")
                    .pretendardFont(.SubTitle)

                Text(shoe.summary)
                    .pretendardFont(.BlockText)
            }
            .foregroundStyle(.black01)

            HStack(spacing: 0) {
                ForEach(shoe.fitPoints) { point in
                    ShoeFitPointBox(point: point)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    ShoeFitSummarySection(shoe: .mock)
        .padding()
}
