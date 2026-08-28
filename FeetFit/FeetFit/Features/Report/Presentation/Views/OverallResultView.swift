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

    init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }

    #if DEBUG
    init(selectedDate: Date, previewResult: DailyFootAnalysisResultDTO) {
        self.selectedDate = selectedDate
        _viewModel = StateObject(wrappedValue: OverallResultViewModel(mockResult: previewResult))
    }
    #endif

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
                    pressureAndFootprintSection(result)
                    sizeSection(result)
                    environmentSection(result)

                    if let careTips = result.careTips, !careTips.isEmpty {
                        manageTipSection(result)
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .task(id: selectedDate) {
            guard !viewModel.isMock else { return }
            await viewModel.fetchDailyFootAnalysis(date: selectedDate)
        }
    }

    // TODO: 발 컨디션 삭제
    private func conditionSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        MainBox(
            title: "오늘의 발 컨디션",
            status: result.conditionStatus,
            listContent: result.conditionComments,
            content: nil
        )
    }

    // MARK: - 자세 균형
    private func balanceSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        ScoreView(
            score: result.balanceScoreInt,
            title: "자세 균형",
            description: result.balanceComment,
            difference: result.balanceScoreDiffInt
        )
    }

    // MARK: - 압력 분포 및 발 눌림

    private func pressureAndFootprintSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("압력 분포 및 발 눌림 분석")
                .pretendardFont(.BlockTitle)
            
            VStack(alignment: .leading, spacing: 16) {
                pressureSection(result)
                Text("상세 설명")
                    .pretendardFont(.BlockText)
                    .padding(.horizontal, 4)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                footprintSection(result)
                Text(result.plantarFootprintAnalysisText)
                    .pretendardFont(.BlockText)
                    .padding(.horizontal, 4)
            }
        }
        .foregroundStyle(.black01)
        .padding(20)
        .mainBoxStyle()
    }
    
    private func pressureSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        HStack(spacing: 15) {
            makePressureItem(
                title: "왼발",
                value: result.leftPressureInt,
                imageUrl: result.leftPressureImageUrl
            )

            makePressureItem(
                title: "오른발",
                value: result.rightPressureInt,
                imageUrl: result.rightPressureImageUrl
            )
        }
    }

    private func footprintSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        HStack(spacing: 20) {
            pressureImageView(result.leftPlantarFootprintImageUrl)

            pressureImageView(result.rightPlantarFootprintImageUrl)
        }
        .padding(20)
        .gradientBoxStyle()
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
        .gradientBoxStyle()
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

    // MARK: - 발 수치
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

    // MARK: - 발 환경 상태
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

    // MARK: - 관리팁
    private func manageTipSection(_ result: DailyFootAnalysisResultDTO) -> some View {
        MainBox(
            title: "오늘의 관리 팁",
            status: .none,
            listContent: result.careTips ?? [],
            content: nil
        )
    }
}

#if DEBUG
#Preview {
    OverallResultView(selectedDate: Date(), previewResult: .mock)
}
#endif
