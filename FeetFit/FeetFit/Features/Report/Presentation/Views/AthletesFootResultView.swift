//
//  AthletesFootResultView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct AthletesFootResultView: View {
    // MARK: - Properties
    
    @State private var selectedImageType: AthleteImageType = .suspiciousMap

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
        VStack(alignment: .leading, spacing: 10) {
            ScoreView(score: 59, description: "왼쪽 엄지·둘째 발톱에서 무좀 의심 신호가 보여, 변색·손상 관리가 필요합니다.", difference: 1)
            
            Text("무좀 의심 영역 70% + 염증 반응 영역 30%으로 계산됩니다.\n51 × 0.7 + 76 × 0.3 = 58.5점으로 계산되었습니다.")
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
    
    private var imageSection: some View {
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
                if selectedImageType == .suspiciousMap {
                    // TODO: 의심 부위 지도 서버 이미지
                    Rectangle()
                        .fill(.gray02)
                        .overlay {
                            Text("의심 부위 지도")
                                .pretendardFont(.Caption)
                                .foregroundStyle(.gray01)
                        }
                        .frame(height: 300)
                    
                    Rectangle()
                        .fill(.gray02)
                        .overlay {
                            Text("의심 부위 지도")
                                .pretendardFont(.Caption)
                                .foregroundStyle(.gray01)
                        }
                        .frame(height: 300)
                } else {
                    // TODO: 원본 서버 이미지
                    Rectangle()
                        .fill(.gray02)
                        .overlay {
                            Text("원본 이미지")
                                .pretendardFont(.Caption)
                                .foregroundStyle(.gray01)
                        }
                        .frame(height: 300)
                    
                    Rectangle()
                        .fill(.gray02)
                        .overlay {
                            Text("원본 이미지")
                                .pretendardFont(.Caption)
                                .foregroundStyle(.gray01)
                        }
                        .frame(height: 300)
                }
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
                Text("무좀 안정도 분석 결과")
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
            }
            
            // 왼발
            VStack(spacing: 10) {
                Text("무좀 의심 영역 안정도")
                    .pretendardFont(.SectionTitle)
                GaugeView(type: .athletesFoot, current: 51)
                Text("왼쪽 엄지발톱과 둘째 발톱에서 변색 및 표면 손상 의심 신호가 확인되었습니다. 발톱 상태가 정상보다 낮게 평가되어 지속적인 관찰과 관리가 필요합니다.")
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
            
            // 오른발
            VStack(spacing: 10) {
                Text("피부 반응 안정도")
                    .pretendardFont(.SectionTitle)
                GaugeView(type: .athletesFoot, current: 76)
                Text("왼쪽 발가락 주변 피부에서 약한 붉은기가 확인됩니다. 심한 부기나 짓무름은 뚜렷하지 않지만, 피부 자극 또는 염증 반응 가능성이 있어 관리가 필요합니다.")
                    .multilineTextAlignment(.leading)
                    .pretendardFont(.BlockText)
            }
        }
        .padding(20)
        .mainBoxStyle()
    }
}

#Preview {
    AthletesFootResultView()
}
