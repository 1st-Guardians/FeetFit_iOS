//
//  HealthNews.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import Foundation

struct HealthNews: Identifiable {
    let id: Int
    let title: String
    let url: String
    let publisher: String
    let publishedAt: String
    let healthType: String
    let description: String
}
