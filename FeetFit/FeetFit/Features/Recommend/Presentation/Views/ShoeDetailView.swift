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
        GeometryReader { geometry in
            if let shoe = viewModel.shoe {
                detailContent(shoe: shoe, geometry: geometry)
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
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchDetail()
        }
    }
    
    private func detailContent(shoe: ShoeDetailInfo, geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let shoeWidth = min(max(screenWidth * 0.9, 210), 280)
        let shoeTrailingPadding = screenWidth * 0.02
        let shoeTopOffset = -shoeWidth * 0.2
        let contentTopPadding = shoeWidth * 0.24
        
        return ZStack(alignment: .top) {
            background
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topGroup(shoe: shoe)
                    
                    ZStack(alignment: .topTrailing) {
                        contentGroup(shoe: shoe)
                        
                        productImage(urlString: shoe.imageURL, width: shoeWidth)
                            .padding(.trailing, shoeTrailingPadding)
                            .offset(y: shoeTopOffset)
                            .zIndex(1)
                    }
                    .padding(.top, contentTopPadding)
                }
                .padding(.bottom, 110)
            }
        }
    }
    
    private func productImage(urlString: String, width: CGFloat) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: width, height: width)
                
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: width)
                
            case .failure:
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.gray01)
                    .frame(width: width, height: width)
                
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var background: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(.clear)
                .blueLinear()
            
            Color.white
        }
    }
    
    private func topGroup(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.tint(.white.opacity(0.25)), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(shoe.name)
                    .pretendardFont(.SubTitle)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                
                Text(shoe.brand)
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.white)
                
                Text(shoe.formattedPrice)
                    .pretendardFont(.Title)
                    .foregroundStyle(.white)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
        }
    }
    
    private func contentGroup(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ratingSection(shoe: shoe)
                .padding(.top, 64)
            
            pointSummarySection(shoe: shoe)
                .padding(.top, 20)
            
            fitPointSection(shoe: shoe)
                .padding(.top, 20)
            
            fitScoreTitle(shoe: shoe)
                .padding(.top, 25)
            
            analysisCardList(shoe: shoe)
                .padding(.top, 15)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
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
        .padding(.horizontal, 16)
    }
    
    private func pointSummarySection(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("한 눈에 보는 착용 포인트")
                .pretendardFont(.SubTitle)
                .foregroundStyle(.black)
            
            Text(shoe.summary)
                .pretendardFont(.BlockText)
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 16)
    }
    
    private func fitPointSection(shoe: ShoeDetailInfo) -> some View {
        HStack(spacing: 19) {
            ForEach(shoe.fitPoints) { point in
                ShoeFitPointBox(point: point)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func fitScoreTitle(shoe: ShoeDetailInfo) -> some View {
        HStack(spacing: 5) {
            Text("나와의 적합도 \(shoe.formattedFitScore)")
                .pretendardFont(.SubTitle)
                .foregroundStyle(.black)
                .padding(.leading, 16)
            
            TooltipButton(message:
                """
                발 압력, 보행 패턴, 발 구조 분석 결과와 실제 사용자 착화 데이터를 기반으로 계산된 적합도 점수입니다. 사용자의 발 특성과 유사한 패턴을 가진 착화 데이터를 비교하여, 부위별 압력 분포와 불편 발생 경향을 반영한 유사도 점수를 산출하고 이를 종합하여 최종 적합도를 계산합니다.
                """
            )
            .foregroundStyle(.black01)
        }
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
