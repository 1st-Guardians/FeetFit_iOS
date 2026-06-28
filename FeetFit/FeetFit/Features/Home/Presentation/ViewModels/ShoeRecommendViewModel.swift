//
//  ShoeRecommendViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Combine

@MainActor
final class ShoeRecommendViewModel: ObservableObject {
    @Published var shoes: [ShoeInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchRecommendations() async {
        isLoading = true
        errorMessage = nil

        do {
            shoes = try await HomeAPI.shared.fetchShoeRecommendations()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
