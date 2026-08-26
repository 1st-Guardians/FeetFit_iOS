//
//  TodayShoesRecommendView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct TodayShoesRecommendView: View {
    @StateObject private var viewModel = ShoeRecommendViewModel()
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                tabRouter.selectedTab = .recommend
            } label: {
                HStack {
                    Text("오늘의 측정 결과로 신발 추천 받기")
                        .pretendardFont(.BlockTitle)
                    Spacer()

                    if !viewModel.shoes.isEmpty {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)

            if !viewModel.shoes.isEmpty {
                listView
            } else {
                emptyView
            }
        }
        .task {
            await viewModel.fetchRecommendations()
        }
    }

    // MARK: - SubView

    private var emptyView: some View {
        Text("아직 추천된 신발이 없어요.\n발 상태를 측정해 보세요.")
            .multilineTextAlignment(.center)
            .pretendardFont(.BlockText)
            .foregroundStyle(.gray01)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .mainBoxStyle()
    }

    private var listView: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.shoes.enumerated()), id: \.element.id) { index, shoe in
                Button {
                    if let url = URL(string: shoe.shoeURL) {
                        openURL(url)
                    }
                } label: {
                    ShoeInfoView(shoe: shoe)
                }
                .buttonStyle(.plain)

                if index != viewModel.shoes.count - 1 {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
        .mainBoxStyle()
    }
}

#Preview {
    TodayShoesRecommendView()
        .environmentObject(TabRouter())
}
