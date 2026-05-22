//
//  AthletesFootResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct AthletesFootResultView: View {
    var body: some View {
        VStack(spacing: 15) {
            conditionSection
            
            valanceSection
            
            pressureSection
            
            sizeSection
            
            smellSection
            
            environmentSection
            
            manageTipSection
        }
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
        VStack {
            
        }
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
        VStack {
            
        }
    }
    
    // 발 냄새
    private var smellSection: some View {
        VStack {
            
        }
    }
    
    // 발 환경 상태
    private var environmentSection: some View {
        VStack {
            
        }
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
    AthletesFootResultView()
}
