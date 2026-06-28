//
//  HomeView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @Environment(NavigationRouter<HomeRoute>.self) private var router
    @StateObject private var weeklyStatusViewModel = WeeklyStatusViewModel()

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    topSection
                        .padding(.vertical, 26)

                    WeekCalendarView(
                        dailyStatuses: weeklyStatusViewModel.weeklyStatus?.dailyStatuses ?? [],
                        today: weeklyStatusViewModel.weeklyStatus?.today ?? "",
                        onDateSelected: { date in
                            router.push(.report(date))
                        }
                    )

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
        .task {
            await weeklyStatusViewModel.fetchWeeklyStatus()
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
        let status = weeklyStatusViewModel.homeStatus

        return VStack(alignment: .leading, spacing: 10) {
            Text(status.title)
                .pretendardFont(.SubTitle)

            Text(status.description)
                .pretendardFont(.Description)

            Spacer().frame(height: 10)

            Button(action: {
                switch status {
                case .noRecord, .notMeasuredToday:
                    router.push(.measurement)

                case .measuredToday:
                    router.push(.report(Date()))
                }
            }) {
                Text(status.buttonText)
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
