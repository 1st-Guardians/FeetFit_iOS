//
//  ShoeFitScoreSection.swift
//  FeetFit
//

import SwiftUI

struct ShoeFitScoreSection: View {
    let shoe: ShoeDetailInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 5) {
                Text("나와의 적합도 \(shoe.formattedFitScore)")
                    .pretendardFont(.SubTitle)
                    .padding(.leading, 8)

                TooltipButton(message:
                    """
                    발 압력, 보행 패턴, 발 구조 분석 결과와 실제 사용자 착화 데이터를 기반으로 계산된 적합도 점수입니다. 사용자의 발 특성과 유사한 패턴을 가진 착화 데이터를 비교하여, 부위별 압력 분포와 불편 발생 경향을 반영한 유사도 점수를 산출하고 이를 종합하여 최종 적합도를 계산합니다.
                    """
                )
            }
            .foregroundStyle(.black01)

            VStack(spacing: 16) {
                ForEach(shoe.analysisCards) { analysis in
                    ShoeAnalysisCard(analysis: analysis)
                }
            }
        }
    }
}

#Preview {
    ShoeFitScoreSection(shoe: .mock)
        .padding()
}
