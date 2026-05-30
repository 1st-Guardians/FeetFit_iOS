//
//  ScoreView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI
import Charts

struct ScoreView: View {
    
    // MARK: - Properties
    
    private let score: Int
    private let title: String?
    private let description: String
    private let difference: Int?
    
    init(
        score: Int,
        title: String? = nil,
        description: String,
        difference: Int?
    ) {
        self.score = min(max(score, 0), 100)
        self.title = title
        self.description = description
        self.difference = difference
    }
    
    private var remainingScore: Int {
        100 - score
    }
    
    private var differenceText: String {
        guard let difference else {
            return "이전 측정 데이터 없음"
        }

        if difference > 0 {
            return "지난 측정 대비 +\(difference)"
        } else if difference < 0 {
            return "지난 측정 대비 \(difference)"
        } else {
            return "지난 측정과 동일"
        }
    }

    private var differenceIcon: String {
        guard let difference else {
            return "minus"
        }

        if difference > 0 {
            return "arrow.up.right"
        } else if difference < 0 {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            if let title {
                Text(title)
                    .pretendardFont(.BlockTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 20) {
                chartView
                
                textSection
            }
        }
        .foregroundStyle(.black01)
        .padding(20)
        .mainBoxStyle()
    }
    
    // MARK: - SubViews
    
    private var chartView: some View {
        Chart {
            SectorMark(
                angle: .value("Score", score),
                innerRadius: .ratio(0.8)
            )
            .foregroundStyle(scoreGradient)
            
            SectorMark(
                angle: .value("Remaining", remainingScore),
                innerRadius: .ratio(0.8)
            )
            .foregroundStyle(.clear)
        }
        .frame(width: 120, height: 120)
        .overlay {
            HStack(alignment: .bottom, spacing: 2) {
                Text("\(score)")
                    .pretendardFont(.ScoreText)
                
                Text("점")
                    .pretendardFont(.BlockText)
                    .padding(.bottom, 10)
            }
        }
    }
    
    private var scoreGradient: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(
                    color: Color(red: 0.09, green: 0.63, blue: 0.98),
                    location: 0.00
                ),
                Gradient.Stop(
                    color: Color(red: 0.00, green: 0.46, blue: 0.86),
                    location: 1.00
                )
            ],
            startPoint: UnitPoint(x: 0.04, y: 0.73),
            endPoint: UnitPoint(x: 0.97, y: 0.28)
        )
    }
    
    private var textSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(description)
                .pretendardFont(.BlockText)
                .lineLimit(5)
            
            Label(differenceText, systemImage: differenceIcon)
                .pretendardFont(.BlockText)
                .foregroundStyle(.blue01)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        ScoreView(
            score: 82,
            title: "종합 점수",
            description: "전반적으로 발 상태가 안정적이에요.",
            difference: 6
        )
        
        ScoreView(
            score: 64,
            description: "압력 균형 관리가 조금 필요해요.",
            difference: -3
        )
        
        ScoreView(
            score: 75,
            title: "무좀 위험도",
            description: "습도와 피부 상태가 양호한 편이에요.",
            difference: 0
        )
    }
    .padding()
    .background(Color.gray.opacity(0.08))
}
