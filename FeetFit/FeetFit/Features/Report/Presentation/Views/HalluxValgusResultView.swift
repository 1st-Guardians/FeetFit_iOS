//
//  HalluxValgusResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct HalluxValgusResultView: View {
    let selectedDate: Date
    @StateObject private var viewModel = HalluxValgusResultViewModel()
    
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
            await viewModel.fetchHalluxValgus(date: selectedDate)
        }
    }
    
    private func scoreSection(_ result: HalluxValgusResultDTO) -> some View {
        ScoreView(
            score: result.riskScoreInt,
            description: result.scoreAnalysisText,
            difference: result.riskScoreDiffInt
        )
    }
    
    private func imageSection(_ result: HalluxValgusResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("분석 이미지")
                    .pretendardFont(.BlockTitle)
                
                Text("외곽선 및 키포인트 추출")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }
            HStack(spacing: 20) {
                analysisImageView(result.leftImageUrl)
                
                analysisImageView(result.rightImageUrl)
            }
            .padding(20)
            .gradientBoxStyle()
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    @ViewBuilder
    private func analysisImageView(_ imageUrl: String?) -> some View {
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
                    .frame(height: 150)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Rectangle()
                .fill(.gray02)
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func gaugeSection(_ result: HalluxValgusResultDTO) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("상세 설명")
                    .pretendardFont(.BlockTitle)
                
                Text("무지외반 위험도 분석 결과")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }
            
            VStack(spacing: 10) {
                Text("왼발")
                    .pretendardFont(.SectionTitle)
                
                GaugeView(
                    type: .halluxValgus,
                    current: result.leftToeAngleCGFloat
                )
                
                Text(result.leftAnalysisText)
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
            
            VStack(spacing: 10) {
                Text("오른발")
                    .pretendardFont(.SectionTitle)
                
                GaugeView(
                    type: .halluxValgus,
                    current: result.rightToeAngleCGFloat
                )
                
                Text(result.rightAnalysisText)
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
        }
        .padding(20)
        .mainBoxStyle()
    }
}
