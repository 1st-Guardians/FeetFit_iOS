//
//  HomeView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    
    // 임시
    private let measuredDates: [Date] = [
        Date(),
        Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    ]
    
    private var homeStatus: HomeStatus {
        if measuredDates.isEmpty {
            return .noRecord
        }
        
        let calendar = Calendar.current
        let hasTodayRecord = measuredDates.contains {
            calendar.isDateInToday($0)
        }
        
        return hasTodayRecord ? .measuredToday : .notMeasuredToday
    }
    
    var body: some View {
        ZStack {
            background
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    topSection
                        .padding(.vertical, 26)
                    
                    WeekCalendarView(measuredDates: measuredDates)
                    
                    StretchingView()
                    
                    HealthNewsView()
                    
                    TodayShoesRecommendView()
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .foregroundStyle(.black01)
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationBarBackButtonHidden()
        }
    }
    
    // MARK: - SubView
    
    private var background: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 402, height: 372)
                .blueLinear()

            Spacer()
        }
    }
    
    private var topSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(homeStatus.title)
                .pretendardFont(.SubTitle)
            
            Text(homeStatus.description)
                .pretendardFont(.Description)
            
            Spacer().frame(height: 10)
            
            Button(action: {
                switch homeStatus {
                case .noRecord, .notMeasuredToday:
                    // TODO: 측정하러 가기
                    break
                    
                case .measuredToday:
                    // TODO: 결과 확인하러 가기
                    break
                }
            }) {
                Text(homeStatus.buttonText)
                    .pretendardFont(.Description)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.glass)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    HomeView()
}
