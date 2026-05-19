//
//  HealthNewsView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct HealthNewsView: View {
    
    // MARK: - Properties
    
    private let newsList: [HealthNews] = [
        HealthNews(company: "동아일보", title: "최근 족저근막염 환자 15.4% 증가..."),
        HealthNews(company: "세계비즈", title: "키높이 신발 유행에 무지외반증↑... 심한 경우 수술 필요"),
        HealthNews(company: "코메디닷컴", title: "무지외반, 족저근막... 늘어가는 현대인 발병"),
        HealthNews(company: "동아일보", title: "최근 족저근막염 환자 15.4% 증가...")
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("건강 이슈")
                .pretendardFont(.BlockTitle)
                .padding(.leading, 8)
            
            listView
        }
    }
    
    private var listView: some View {
        VStack(spacing: 0) {
            ForEach(Array(newsList.enumerated()), id: \.element.id) { index, news in
                newsRow(news)
                
                if index != newsList.count - 1 {
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
            Text(news.company)
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
