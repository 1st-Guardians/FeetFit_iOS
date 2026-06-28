//
//  StretchingView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct StretchingView: View {
    @StateObject private var viewModel = StretchingViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("스트레칭 TODO")
                .pretendardFont(.BlockTitle)
                .padding(.leading, 8)

            if !viewModel.todos.isEmpty {
                listView
            } else {
                emptyView
            }
        }
        .task {
            await viewModel.fetchTodos()
        }
    }

    // MARK: - SubView
    private var emptyView: some View {
        Text("아직 생성된 스트레칭 TODO가 없어요.\n발 상태를 측정해 보세요.")
            .multilineTextAlignment(.center)
            .pretendardFont(.Description)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .mainBoxStyle()
    }

    private var listView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.todos.indices, id: \.self) { index in
                Button {
                    viewModel.todos[index].isCompleted.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: viewModel.todos[index].isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))

                        Text(viewModel.todos[index].title)
                            .pretendardFont(.Description)
                            .strikethrough(viewModel.todos[index].isCompleted, color: .gray02)

                        Spacer()
                    }
                    .foregroundStyle(viewModel.todos[index].isCompleted ? .gray02 : .black01)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .frame(height: 50)

                if index != viewModel.todos.indices.last {
                    Divider()
                        .background(.gray02)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .mainBoxStyle()
    }
}

#Preview {
    StretchingView()
}
