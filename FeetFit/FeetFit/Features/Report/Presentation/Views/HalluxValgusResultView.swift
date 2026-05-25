//
//  HalluxValgusResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct HalluxValgusResultView: View {
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                scoreSection
                
                imageSection
                
                gaugeSection
            }
            .foregroundStyle(.black01)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - SubViews
    
    private var scoreSection: some View {
        ScoreView(score: 93, description: "엄지발가락의 외반 각도가 12도로 정상 범위 내이며, 전체적인 발 정렬이 안정적입니다.", difference: 4)
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("분석 이미지")
                    .pretendardFont(.BlockTitle)
                Text("외곽선 및 키포인트 추출")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }
            
            HStack {
                // TODO: 서버 이미지
                
                Rectangle().fill(.gray02)
                    .frame(height: 200)
                
                Rectangle().fill(.gray02)
                    .frame(height: 200)
            }
            .padding(20)
            .gradientBoxStyle()
        }
        .padding(20)
        .mainBoxStyle()
    }
    
    private var gaugeSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 타이틀
            VStack(alignment: .leading, spacing: 4) {
                Text("상세 설명")
                    .pretendardFont(.BlockTitle)
                Text("무지외반 위험도 분석 결과")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }
            
            // 왼발
            VStack(spacing: 10) {
                Text("왼발")
                    .pretendardFont(.SectionTitle)
                GaugeView(type: .halluxValgus, current: 12)
                Text("엄지발가락이 두 번째 발가락 쪽으로 기울어진 각도(HVA)가 12°로 측정되었습니다. 정상 기준(15° 이하)에 해당합니다.")
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
            
            // 오른발
            VStack(spacing: 10) {
                Text("오른발")
                    .pretendardFont(.SectionTitle)
                GaugeView(type: .halluxValgus, current: 12)
                Text("엄지발가락이 두 번째 발가락 쪽으로 기울어진 각도(HVA)가 12°로 측정되었습니다. 정상 기준(15° 이하)에 해당합니다.")
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
        }
        .padding(20)
        .mainBoxStyle()
    }
}

#Preview {
    HalluxValgusResultView()
}
