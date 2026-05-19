//
//  StretchingView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct StretchingView: View {
    // 임시
    @State private var todoList: [StretchingTodo] = [
        StretchingTodo(title: "발목을 천천히 돌려 주세요."),
        StretchingTodo(title: "발가락을 위아래로 움직여 주세요."),
        StretchingTodo(title: "종아리를 가볍게 늘려 주세요.")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("스트레칭 TODO")
                .pretendardFont(.BlockTitle)
                .padding(.leading, 8)
            
            if !todoList.isEmpty {
                listView
            } else {
                emptyView
            }
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
            ForEach(todoList.indices, id: \.self) { index in
                Button {
                    todoList[index].isCompleted.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: todoList[index].isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                        
                        Text(todoList[index].title)
                            .pretendardFont(.Description)
                            .strikethrough(todoList[index].isCompleted, color: .gray02)
                        
                        Spacer()
                    }
                    .foregroundStyle(todoList[index].isCompleted ? .gray02 : .black01)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .frame(height: 50)
                
                if index != todoList.indices.last {
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
