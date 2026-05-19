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
    private let content: String
    private let status: MainBoxStatus
    private let listContent: [String]?
    
    init(title: String, content: String, status: MainBoxStatus, listContent: [String]? = nil) {
        self.title = title
        self.content = content
        self.status = status
        self.listContent = listContent
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
            
            // 리스트
            if let listContent = listContent, !listContent.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(listContent, id: \.self) { content in
                        Text(" ∙ " + content)
                            .pretendardFont(.BlockText)
                    }
                    
                    Divider()
                }
            }
            
            // 내용
            Text(content)
                .pretendardFont(.BlockText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .mainBoxStyle()
    }
}

#Preview {
    MainBox(
        title: "제목", content: "내용", status: .good,
        listContent: [
            "list 1", "list 2", "list 3"
        ]
    )
}
