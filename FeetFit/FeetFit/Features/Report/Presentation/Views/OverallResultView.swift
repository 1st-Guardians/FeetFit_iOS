//
//  OverallResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct OverallResultView: View {
    let selectedDate: Date
    @StateObject private var viewModel = OverallResultViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if viewModel.isLoading && viewModel.result == nil {
                    ProgressView()
                        .padding(.top, 40)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .pretendardFont(.BlockText)
                        .foregroundStyle(.gray01)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if let result = viewModel.result {
                    conditionSection(result)
                    balanceSection(result)
                    pressureSection(result)
                    sizeSection(result)
                    environmentSection(result)
                    manageTipSection(result)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .task(id: selectedDate) {
            await viewModel.fetchDailyFootAnalysis(date: selectedDate)
        }
    }

    private func conditionSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        MainBox(
            title: "오늘의 발 컨디션",
            status: result.conditionStatus,
            listContent: result.conditionComments,
            content: nil
        )
    }

    private func balanceSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        ScoreView(
            score: result.balanceScoreInt,
            title: "자세 균형",
            description: result.balanceComment,
            difference: result.balanceScoreDiffInt
        )
    }

    private func pressureSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        HStack(spacing: 15) {
            makePressureItem(
                title: "왼발 압력 분포",
                value: result.leftPressureInt,
                imageUrl: result.leftPressureImageUrl
            )

            makePressureItem(
                title: "오른발 압력 분포",
                value: result.rightPressureInt,
                imageUrl: result.rightPressureImageUrl
            )
        }
    }

    private func makePressureItem(
        title: String,
        value: Int,
        imageUrl: String?
    ) -> some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .pretendardFont(.BlockTitle)

                Text("\(value)%")
                    .pretendardFont(.ScoreText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            pressureImageView(imageUrl)
        }
        .padding(20)
        .mainBoxStyle()
    }

    @ViewBuilder
    private func pressureImageView(_ imageUrl: String?) -> some View {
        if let imageUrl,
           let url = URL(string: imageUrl),
           !imageUrl.isEmpty {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Rectangle()
                .fill(.gray02)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func sizeSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("발 수치")
                .pretendardFont(.BlockTitle)

            Divider()
                .background(.gray02)

            FootSizeTableView(rows: result.footSizeRows)
        }
        .padding(20)
        .mainBoxStyle()
    }

    private func environmentSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("발 환경 상태")
                .pretendardFont(.BlockTitle)

            EnvironmentGaugeView(
                type: .temperature,
                value: result.temperatureValue
            )

            EnvironmentGaugeView(
                type: .humidity,
                value: result.humidityValue
            )
        }
        .padding(20)
        .mainBoxStyle()
    }

    private func manageTipSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        MainBox(
            title: "오늘의 관리 팁",
            status: .none,
            listContent: result.careTips,
            content: nil
        )
    }
}
