//
//  HealthNewsViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Combine

@MainActor
final class HealthNewsViewModel: ObservableObject {
    @Published var articles: [HealthNews] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchArticles() async {
        isLoading = true
        errorMessage = nil

        do {
            articles = try await HomeAPI.shared.fetchArticles()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
