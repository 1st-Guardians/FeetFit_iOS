//
//  ShoeAnalysisCard.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeAnalysisCard: View {
    let analysis: ShoeFitAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(analysis.title)
                    .pretendardFont(.BlockTitle)
                    .foregroundStyle(.black)
                
                HStack(spacing: 3) {
                    Circle()
                        .fill(analysis.status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(analysis.status.title)
                        .pretendardFont(.Caption)
                        .foregroundStyle(analysis.status.color)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysis.reviewQuotes, id: \.self) { quote in
                    Text("•  “\(quote)”")
                        .pretendardFont(.BlockText)
                        .foregroundStyle(.black)
                }
            }
            
            Divider()
            
            Text(analysis.description)
                .pretendardFont(.BlockText)
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .mainBoxStyle()
    }
}


#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ShoeAnalysisCard(
                analysis: ShoeFitAnalysis(
                    id: 1,
                    title: "깔창 얇음",
                    status: .bad,
                    reviewQuotes: [
                        "깔창이 얇아서 오래 걸으면 발바닥이 조금 피로했어요.",
                        "쿠션감이 크지 않고 바닥이 얇은 편입니다.",
                        "디자인은 예쁘지만 푹신한 느낌은 적었어요."
                    ],
                    description: "사용자의 발 압력 데이터에서 뒤꿈치와 전족부에 하중 집중이 나타났습니다. 이 제품은 깔창이 얇아 충격 흡수를 충분히 제공하지 못할 수 있습니다. 장시간 착용 시 발 피로가 증가할 가능성이 있어 주의가 필요합니다."
                )
            )
            
            ShoeAnalysisCard(
                analysis: ShoeFitAnalysis(
                    id: 2,
                    title: "뒤꿈치 까짐 주의",
                    status: .warn,
                    reviewQuotes: [
                        "처음 신었을 때 뒤꿈치가 조금 까졌어요.",
                        "뒷부분이 단단해서 오래 신으면 마찰이 느껴졌습니다."
                    ],
                    description: "사용자의 보행 패턴에서 뒤꿈치 압력 집중이 일부 확인됩니다. 착용 초반에는 마찰로 인한 불편이 발생할 수 있습니다."
                )
            )
            
            ShoeAnalysisCard(
                analysis: ShoeFitAnalysis(
                    id: 3,
                    title: "발볼 넓음",
                    status: .good,
                    reviewQuotes: [
                        "발볼이 여유 있게 나와서 편하게 신을 수 있었어요.",
                        "평소 발볼이 넓은 편인데도 답답하지 않았습니다."
                    ],
                    description: "사용자의 발 구조 분석 결과, 발볼이 큰 편에 해당합니다. 발볼 여유가 있는 신발은 압박을 줄여 더 편안한 착용감을 제공할 수 있습니다."
                )
            )
        }
        .padding()
    }
}
