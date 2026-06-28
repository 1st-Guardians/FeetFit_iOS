//
//  HealthNewsView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct HealthNewsView: View {
    @StateObject private var viewModel = HealthNewsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("건강 이슈")
                .pretendardFont(.BlockTitle)
                .padding(.leading, 8)

            if !viewModel.articles.isEmpty {
                listView
            } else {
                emptyView
            }
        }
        .task {
            await viewModel.fetchArticles()
        }
    }

    // MARK: - SubView

    private var emptyView: some View {
        Text("아직 연결된 건강 이슈가 없어요.\n발 상태를 측정해 보세요.")
            .multilineTextAlignment(.center)
            .pretendardFont(.Description)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .mainBoxStyle()
    }

    private var listView: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, news in
                newsRow(news)

                if index != viewModel.articles.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .mainBoxStyle()
    }

    private func newsRow(_ news: HealthNews) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(news.publisher)
                .pretendardFont(.Caption)
                .foregroundStyle(.gray)

            Text(news.title)
                .pretendardFont(.Description)
                .foregroundStyle(.black)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

#Preview {
    HealthNewsView()
}
