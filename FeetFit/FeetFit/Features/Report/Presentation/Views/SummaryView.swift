//
//  SummaryView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI
import Charts

struct SummaryView: View {
    @StateObject private var viewModel = SummaryViewModel()
    @State private var isTooltipPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isLoading && viewModel.report == nil {
                    ProgressView()
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .pretendardFont(.BlockText)
                        .foregroundStyle(.gray01)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    totalScoreSection
                    yearSection
                    listSection
                }
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .task {
            await viewModel.fetchSummary()
        }
    }

    private var totalScoreSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 5) {
                Text("당신의 발 종합 점수는")
                    .pretendardFont(.BlockText)

                Text(viewModel.totalScoreText)
                    .pretendardFont(.SubTitle)

                // TODO: 발냄새, 무좀 수정 필요
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

            RadarChartView(items: viewModel.radarItems)
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

            YearChartView(chartData: viewModel.yearScores)
        }
        .padding(20)
        .mainBoxStyle()
    }

    private var listSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.metricScores) { metric in
                MainBox(
                    title: metric.displayTitle,
                    status: metric.mainBoxStatus,
                    listContent: metric.advice,
                    content: nil
                )
            }
        }
    }
}

#Preview {
    SummaryView()
}
