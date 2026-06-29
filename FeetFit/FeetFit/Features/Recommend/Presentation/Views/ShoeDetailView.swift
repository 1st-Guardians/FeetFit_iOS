//
//  ShoeDetailView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ShoeDetailViewModel
    
    init(shoeId: Int) {
        _viewModel = StateObject(wrappedValue: ShoeDetailViewModel(shoeId: shoeId))
    }
    
    var body: some View {
        Group {
            if let shoe = viewModel.shoe {
                detailContent(shoe: shoe)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            } else {
                VStack(spacing: 12) {
                    Text(viewModel.errorMessage ?? "신발 정보를 불러오지 못했습니다.")
                        .pretendardFont(.BlockText)
                        .foregroundStyle(.gray01)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("돌아가기")
                            .pretendardFont(.BlockText)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.white)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                dismiss()
            }
        }
        .onAppear {
            viewModel.fetchDetail()
        }
    }
    
    private func detailContent(shoe: ShoeDetailInfo) -> some View {
        return ZStack(alignment: .top) {
            productImage(urlString: shoe.imageURL)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 165)
                    
                    VStack(alignment: .leading, spacing: 32) {
                        topGroup(shoe: shoe)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            pointSummarySection(shoe: shoe)
                            
                            fitPointSection(shoe: shoe)
                        }
                        .padding(.horizontal, 8)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            fitScoreTitle(shoe: shoe)
                            
                            analysisCardList(shoe: shoe)
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 40,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 40
                        )
                        .fill(.white)
                    }
                }
            }
        }
    }
    
    private func productImage(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 320)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 320)
                    .clipped()
                
            case .failure:
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.gray01)
                    .frame(height: 320)
                
            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }
    
    private func topGroup(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shoe.name)
                .pretendardFont(.SubTitle)
            
            Text(shoe.brand)
                .pretendardFont(.BlockText)
            
            Text(shoe.formattedPrice)
                .pretendardFont(.Title)
                .padding(.top, 4)
            
            ratingSection(shoe: shoe)
                .padding(.top, 8)
        }
        .foregroundStyle(.black01)
        .padding(.horizontal, 8)
        .padding(.top, 40)
    }
    
    private func ratingSection(shoe: ShoeDetailInfo) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starName(for: index, rating: shoe.rating))
                    .font(.system(size: 25))
                    .foregroundStyle(.yellow)
            }
            
            TooltipButton(message:
                """
                외부 사이트에서 수집한 실제 사용자 리뷰 별점을 기반으로 계산한 평균 평점이에요. 전체적인 평가를 보여주는 값이며, 개인별 착화감과는 차이가 있을 수 있어요.
                """
            )
            .foregroundStyle(.black01)
            .padding([.top, .leading], 5)
        }
    }
    
    private func pointSummarySection(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("한 눈에 보는 착용 포인트")
                .pretendardFont(.SubTitle)
            
            Text(shoe.summary)
                .pretendardFont(.BlockText)
        }
        .foregroundStyle(.black01)
    }
    
    private func fitPointSection(shoe: ShoeDetailInfo) -> some View {
        HStack(spacing: 0) {
            ForEach(shoe.fitPoints) { point in
                ShoeFitPointBox(point: point)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func fitScoreTitle(shoe: ShoeDetailInfo) -> some View {
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
    }
    
    private func analysisCardList(shoe: ShoeDetailInfo) -> some View {
        VStack(spacing: 16) {
            ForEach(shoe.analysisCards) { analysis in
                ShoeAnalysisCard(analysis: analysis)
            }
        }
    }
    
    private func starName(for index: Int, rating: Double) -> String {
        let fullStarCount = Int(rating)
        let hasHalfStar = rating - Double(fullStarCount) >= 0.5
        
        if index < fullStarCount {
            return "star.fill"
        } else if index == fullStarCount && hasHalfStar {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    NavigationStack {
        ShoeDetailView(shoeId: 1)
    }
}
