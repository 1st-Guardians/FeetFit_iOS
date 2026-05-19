//
//  SummaryView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct SummaryView: View {
    @State private var isTooltipPresented = false
    
    var body: some View {
        VStack {
            totalScoreSection
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - SubView
    
    private var totalScoreSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 5) {
                Text("당신의 발 종합 점수는")
                    .pretendardFont(.BlockText)
                Text("83점")
                    .pretendardFont(.SubTitle)
                
                TooltipButton(
                    message: """
                    각 항목은 **0~100점**으로 환산되며, 상태가 안정적일수록 높은 점수를 받아요.

                    **압력 균형**: 좌우 발 압력 차이
                    **무지외반**: 엄지발가락 휘어짐 정도
                    **발냄새**: 냄새 수치 안정성
                    **무좀**: 무좀 의심 징후
                    **환경 상태**: 온도·습도 적정성
                    """
                )
            }
            .foregroundStyle(.black01)
            
            RadarChartView(
                items: [
                    RadarChartItem(title: "압력 균형", value: 0.8),
                    RadarChartItem(title: "무좀", value: 0.65),
                    RadarChartItem(title: "환경 상태", value: 0.45),
                    RadarChartItem(title: "발냄새", value: 0.72),
                    RadarChartItem(title: "무지외반", value: 0.9)
                ]
            )
        }
        .padding(.top, 20)
        .mainBoxStyle()
    }
}

#Preview {
    SummaryView()
}
