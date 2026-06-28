//
//  ArticleDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation

struct ArticleListResultDTO: Decodable {
    let totalCount: Int
    let articles: [ArticleDTO]
}

struct ArticleDTO: Decodable {
    let articleId: Int
    let title: String
    let url: String
    let publisher: String
    let publishedAt: String
    let healthType: String
    let description: String
}

extension ArticleDTO {
    var toDomain: HealthNews {
        HealthNews(
            id: articleId,
            title: title,
            url: url,
            publisher: publisher,
            publishedAt: publishedAt,
            healthType: healthType,
            description: description
        )
    }
}
