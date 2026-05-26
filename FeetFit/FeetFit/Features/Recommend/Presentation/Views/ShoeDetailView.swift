//
//  ShoeDetailView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let shoe = ShoeDetailInfo(
        id: 1,
        brand: "Puma",
        name: "푸마 x 로제 스피드캣 PRM 블랙 웜 화이트",
        price: 159000,
        rating: 4.5,
        fitScore: 87,
        interestCount: 120,
        imageURL: "shoe_puma_speedcat",
        summary: "발볼이 슬림하게 나온 편이라 발볼 넓으면 반 사이즈 업 추천, 정사이즈는 전체적으로 딱 맞는 핏이다. 로우하고 날렵한 디자인이라 청바지, 슬랙스, 스커트까지 깔끔하게 잘 어울리는 데일리용 스니커즈다. 디자인 위주 신발이라 쿠션감은 크지 않지만 가볍고 예쁘게 신기 좋다.",
        fitPoints: [
            ShoeFitPoint(id: 1, type: .width, status: .good),
            ShoeFitPoint(id: 2, type: .heel, status: .warn),
            ShoeFitPoint(id: 3, type: .insole, status: .bad)
        ],
        analysisCards: [
            ShoeFitAnalysis(
                id: 1,
                title: "깔창 얇음",
                status: .bad,
                reviewQuotes: [
                    "깔창이 얇아서 오래 걸으면 발바닥이 조금 피로했어요.",
                    "쿠션감이 크지 않고 바닥이 얇은 편입니다.",
                    "디자인은 예쁘지만 푹신한 느낌은 적었어요."
                ],
                description: "사용자의 발 압력 데이터에서 뒤꿈치와 전족부에 하중 집중이 나타났습니다. 이 제품은 깔창이 얇아 충격 흡수를 충분히 제공하지 못할 수 있습니다. 장시간 착용 시 발 피로가 증가할 가능성이 있어 주의가 필요합니다."
            ),
            ShoeFitAnalysis(
                id: 2,
                title: "뒤꿈치 까짐 주의",
                status: .warn,
                reviewQuotes: [
                    "처음 신었을 때 뒤꿈치가 조금 까졌어요.",
                    "뒷부분이 단단해서 오래 신으면 마찰이 느껴졌습니다.",
                    "양말을 두껍게 신지 않으면 뒤꿈치가 불편했어요."
                ],
                description: "사용자의 보행 패턴에서 뒤꿈치 압력 집중이 일부 확인됩니다. 뒤꿈치 접지 충격이 큰 경우 마찰이 느껴질 수 있어, 착용 시 약간의 불편이 발생할 수 있습니다."
            ),
            ShoeFitAnalysis(
                id: 3,
                title: "발볼 넓음",
                status: .good,
                reviewQuotes: [
                    "발볼이 여유 있게 나와서 편하게 신을 수 있었어요.",
                    "평소 발볼이 넓은 편인데도 답답하지 않았습니다.",
                    "발볼이 좁은 사람은 조금 헐겁게 느껴질 수도 있어요."
                ],
                description: "사용자의 발 구조 분석 결과, 발볼이 큰 편에 해당합니다. 발볼 여유가 있는 신발은 압박을 줄여 더 편안한 착용감을 제공할 수 있습니다."
            )
        ]
    )
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let shoeWidth = min(max(screenWidth * 0.9, 210), 280)
            let shoeTrailingPadding = screenWidth * 0.02
            let shoeTopOffset = -shoeWidth * 0.2
            let contentTopPadding = shoeWidth * 0.24
            
            ZStack(alignment: .top) {
                background
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        topGroup
                        
                        ZStack(alignment: .topTrailing) {
                            contentGroup
                            
                            productImage(width: shoeWidth)
                                .padding(.trailing, shoeTrailingPadding)
                                .offset(y: shoeTopOffset)
                                .zIndex(1)
                        }
                        .padding(.top, contentTopPadding)
                    }
                    .padding(.bottom, 110)
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func productImage(width: CGFloat) -> some View {
        Image(shoe.imageURL)
            .resizable()
            .scaledToFit()
            .frame(width: width)
    }
    
    private var background: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(.clear)
                .blueLinear()
            
            Color.white
        }
    }
    private var productImage: some View {
        Image(shoe.imageURL)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 280)
            .padding(.leading, 90)
    }
    
    private var topGroup: some View {
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
    
    private var contentGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            ratingSection
                .padding(.top, 64)
            
            pointSummarySection
                .padding(.top, 20)
            
            fitPointSection
                .padding(.top, 20)
            
            fitScoreTitle
                .padding(.top, 25)
            
            analysisCardList
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
    
    private var ratingSection: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starName(for: index))
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
    
    
    private var pointSummarySection: some View {
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
    
    private var fitPointSection: some View {
        HStack(spacing: 19) {
            ForEach(shoe.fitPoints) { point in
                ShoeFitPointBox(point: point)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var fitScoreTitle: some View {
        HStack(spacing: 5) {
            Text("은서님과의 적합도 \(shoe.formattedFitScore)")
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
    
    private var analysisCardList: some View {
        VStack(spacing: 16) {
            ForEach(shoe.analysisCards) { analysis in
                ShoeAnalysisCard(analysis: analysis)
            }
        }
    }
    
    
    private func starName(for index: Int) -> String {
        let fullStarCount = Int(shoe.rating)
        let hasHalfStar = shoe.rating - Double(fullStarCount) >= 0.5
        
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
        ShoeDetailView()
    }
}
