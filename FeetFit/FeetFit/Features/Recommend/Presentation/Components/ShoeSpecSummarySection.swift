//
//  ShoeSpecSummarySection.swift
//  FeetFit
//

import SwiftUI

struct ShoeSpecSummarySection: View {
    let specProfile: ShoeSpecProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("신발 특성 요약")
                .pretendardFont(.SubTitle)
                .padding(.leading, 8)

            RadarChartView(
                items: specProfile.radarItems,
                maxLevel: 3
            )
            .padding(.top, 20)
            .padding(.bottom, 12)
            .mainBoxStyle()

            if let summary = specProfile.summary {
                Text(summary)
                    .pretendardFont(.BlockText)
                    .padding(.leading, 8)
            }
        }
        .foregroundStyle(.black01)
    }
}

#Preview {
    ShoeSpecSummarySection(specProfile: .mock)
        .padding()
}
