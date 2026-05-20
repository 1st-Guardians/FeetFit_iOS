//
//  SummaryView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI
import Charts

struct SummaryView: View {
    @State private var isTooltipPresented = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                totalScoreSection
                yearSection
                listSection
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
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
    
    private var yearSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("1년 발 상태 변화")
                    .pretendardFont(.BlockTitle)
                    .foregroundStyle(.black01)
                
                Text("월별 발 건강 점수 추이를 확인해 보세요.")
                    .pretendardFont(.Caption)
                    .foregroundStyle(.gray01)
            }
            
            YearChartView()
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    private var listSection: some View {
        VStack(spacing: 16) {
            MainBox(title: "자세 균형", status: .bad, listContent: [
                "좌우 발의 압력 분포에 다소 차이가 나타나고 있습니다. 체중이 한쪽으로 치우쳐 전달되고 있어 특정 부위에 부담이 집중될 수 있습니다.",
                "보행 시 체중을 양쪽 발에 고르게 분산하는 습관을 의식하는 것이 필요합니다."
            ], content: nil)
            
            MainBox(title: "무지외반", status: .warn, listContent: [
                "엄지발가락이 안쪽으로 약간 기울어지는 변화가 관찰되며, 발 앞쪽 부담에 주의가 필요합니다.",
                "앞쪽 발에 부담이 커지지 않도록 편한 신발을 착용하고, 발가락 스트레칭과 상태 관리를 꾸준히 해주세요."
            ], content: nil)
            
            MainBox(title: "발냄새", status: .good, listContent: [
                "발냄새를 유발할 수 있는 습도와 냄새 관련 수치가 전반적으로 매우 안정적인 상태입니다.",
                "현재처럼 발을 청결하고 건조하게 관리하면 쾌적한 발 환경을 유지하는 데 도움이 됩니다."
            ], content: nil)
            
            MainBox(title: "무좀", status: .good, listContent: [
                "무좀 의심 징후가 거의 나타나지 않으며, 발 피부 상태가 전반적으로 매우 안정적인 상태입니다.",
                "현재처럼 발을 청결하고 건조하게 관리하면 무좀 발생 가능성을 낮추는 데 도움이 됩니다."
            ], content: nil)
            
            MainBox(title: "환경 상태", status: .bad, listContent: [
                "발 주변의 온도와 습도가 전반적으로 높게 나타나며, 일부 부위에서 열감이나 습기가 오래 유지될 가능성이 있어 발 환경 관리 개선이 필요한 상태입니다.",
                "피부 트러블이나 무좀 위험을 줄이기 위해 발을 청결하고 건조하게 유지하고, 통풍이 잘 되는 신발을 착용해주세요."
            ], content: nil)
        }
    }
}

#Preview {
    SummaryView()
}
