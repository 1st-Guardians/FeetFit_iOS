//
//  AthletesFootResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct AthletesFootResultView: View {
    // MARK: - Properties
    let selectedDate: Date
    
    @StateObject private var viewModel = AthletesFootResultViewModel()
    @State private var selectedImageType: AthleteImageType = .suspiciousMap

    // MARK: - Body

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
                    scoreSection(result)

                    imageSection(result)

                    gaugeSection(result)
                }
            }
            .foregroundStyle(.black01)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .task(id: selectedDate) {
            await viewModel.fetchAthletesFoot(date: selectedDate)
        }
    }

    // MARK: - SubViews

    private func scoreSection(_ result: AthletesFootResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ScoreView(
                score: result.totalScoreInt,
                description: result.totalScoreDescription,
                difference: result.totalScoreDiffInt
            )

            Text(result.scoreFormulaText)
                .pretendardFont(.Caption)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue01.opacity(0.25))
                )
        }
    }

    private func imageSection(_ result: AthletesFootResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("분석 이미지")
                        .pretendardFont(.BlockTitle)
                    Text("의심 영역 시각화")
                        .pretendardFont(.BlockText)
                        .foregroundStyle(.gray01)
                }

                Spacer()

                // 메뉴
                Menu {
                    ForEach(AthleteImageType.allCases, id: \.self) { type in
                        Button {
                            selectedImageType = type
                        } label: {
                            HStack {
                                Text(type.rawValue)

                                if selectedImageType == type {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedImageType.rawValue)
                            .pretendardFont(.BlockText)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.black01)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.gray03)
                    )
                }
            }

            HStack {
                footImageView(
                    imageUrl: result.imageUrl(for: selectedImageType),
                    placeholderText: selectedImageType == .suspiciousMap ? "의심 부위 지도" : "원본 이미지"
                )
            }
            .padding(20)
            .gradientBoxStyle()
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Circle()
                        .foregroundStyle(.blue01)
                        .frame(width: 10, height: 10)
                    
                    Text("무좀 의심/감염 영역")
                        .pretendardFont(.Caption)
                        .foregroundStyle(.gray01)
                }
                
                HStack(spacing: 5) {
                    Circle()
                        .foregroundStyle(.red01)
                        .frame(width: 10, height: 10)
                    
                    Text("염증/피부 반응 영역")
                        .pretendardFont(.Caption)
                        .foregroundStyle(.gray01)
                }
            }
        }
        .padding(20)
        .mainBoxStyle()
    }

    @ViewBuilder
    private func footImageView(
        imageUrl: String?,
        placeholderText: String
    ) -> some View {
        if let imageUrl,
           let url = URL(string: imageUrl),
           !imageUrl.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(4)

                case .failure:
                    Text(placeholderText)
                        .pretendardFont(.Caption)
                        .foregroundStyle(.gray01)
                        .multilineTextAlignment(.center)

                @unknown default:
                    Text(placeholderText)
                        .pretendardFont(.Caption)
                        .foregroundStyle(.gray01)
                        .multilineTextAlignment(.center)
                }
            }
        } else {
            Text(placeholderText)
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
                .multilineTextAlignment(.center)
        }
    }

    private func gaugeSection(_ result: AthletesFootResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // 타이틀
            VStack(alignment: .leading, spacing: 4) {
                Text("상세 설명")
                    .pretendardFont(.BlockTitle)
                Text("무좀 의심 영역 안정도")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }

            // 무좀 의심 영역 안정도
            VStack(alignment: .leading, spacing: 10) {
                GaugeView(
                    type: .athletesFoot,
                    current: result.fungalScoreCGFloat
                )
                .padding(.horizontal, 40)
                Text(result.fungalSuspicionSafetyDescription)
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }

            // 피부 반응 안정도
            VStack(alignment: .leading, spacing: 10) {
                Text("피부 반응 안정도")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                GaugeView(
                    type: .athletesFoot,
                    current: result.skinReactionScoreCGFloat
                )
                .padding(.horizontal, 40)
                Text(result.skinReactionSafetyDescription)
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
        }
        .padding(20)
        .mainBoxStyle()
    }
}
