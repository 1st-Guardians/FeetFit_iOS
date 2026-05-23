//
//  OverallResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct OverallResultView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                conditionSection
                
                valanceSection
                
                pressureSection
                
                sizeSection
                
                smellSection
                
                environmentSection
                
                manageTipSection
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - SubViews
    
    // 발 컨디션
    private var conditionSection: some View {
        MainBox(title: "오늘의 발 컨디션", status: .warn, listContent: [
            "오른발에 압력이 조금 더 실려 있어요", "발 냄새 위험도는 낮은 편이에요"
        ], content: nil)
    }
    
    // 자세 균형 점수
    private var valanceSection: some View {
        ScoreView(score: 72, title: "자세 균형", description: "자세 균형에 대한 내용을 넣을 예정입니다. 자세 균형이 좋은 편이에요.", difference: 4)
    }
    
    // 압력 분포
    private var pressureSection: some View {
        HStack(spacing: 15) {
            makePressureItem(title: "왼발 압력 분포", value: 46)
            makePressureItem(title: "오른발 압력 분포", value: 54)
        }
    }
    
    private func makePressureItem(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 10) {
                Text(title)
                    .pretendardFont(.BlockTitle)
                Text("\(value)%")
                    .pretendardFont(.ScoreText)
            }
            
            Rectangle().fill(.gray02)
                .frame(height: 150)
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    // 발 수치
    private var sizeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("발 수치")
                .pretendardFont(.BlockTitle)
            Divider()
                .background(.gray02)
            FootSizeTableView()
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    // 발 냄새
    private var smellSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("발 냄새")
                .pretendardFont(.BlockTitle)
            GaugeView(type: .greenToRed, current: 0.28, minValue: 0.00, maxValue: 5.00, unit: "ppm")
                .frame(maxWidth: .infinity, alignment: .center)
            Text("발 냄새 위험도는 0.28ppm으로 낮은 편이에요. 냄새 분석 결과를 이 섹션에서 확인할 수 있어요.")
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    // 발 환경 상태
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("발 환경 상태")
                .pretendardFont(.BlockTitle)
            
            EnvironmentGaugeView(type: .temperature, value: 34)
            EnvironmentGaugeView(type: .humidity, value: 50)
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    // 관리 팁
    private var manageTipSection: some View {
        MainBox(title: "오늘의 관리 팁", status: .none, listContent: [
            "오른발 압꿈치 스트레칭을 해주세요",
            "신발은 착용 후 충분히 말려주세요",
            "발볼이 좁은 신발은 피하는 것이 좋아요"
        ], content: nil)
    }
}

#Preview {
    OverallResultView()
}
