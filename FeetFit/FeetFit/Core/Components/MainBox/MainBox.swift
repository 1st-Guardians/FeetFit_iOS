//
//  MainBox.swift
//  FeetFit
//
//  Created by 김미주 on 5/19/26.
//

import SwiftUI

struct MainBox: View {
    
    // MARK: - Properties
    
    private let title: String
    private let status: MainBoxStatus
    private let listContent: [String]
    private let content: String?

    init(title: String, status: MainBoxStatus, listContent: [String], content: String?) {
        self.title = title
        self.status = status
        self.listContent = listContent
        self.content = content
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 상단
            HStack(spacing: 12) {
                Text(title)
                    .pretendardFont(.BlockTitle)
                
                HStack(spacing: 4) {
                    Circle()
                        .frame(width: 8)
                    Text(status.title)
                        .pretendardFont(.Caption)
                }
                .foregroundStyle(status.color)
            }
            
            ForEach(listContent, id: \.self) { content in
                Text(" ∙ " + content)
                    .pretendardFont(.BlockText)
            }
            
            // 내용
            if let content {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                    
                    Text(content)
                        .pretendardFont(.BlockText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .mainBoxStyle()
    }
}

#Preview {
    MainBox(
        title: "제목",
        status: .good,
        listContent: [
            "list 1", "list 2", "list 3"
        ],
        content: "내용"
    )
}
