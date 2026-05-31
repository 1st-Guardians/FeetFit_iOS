//
//  RecommendListViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation
import Combine

@MainActor
final class RecommendListViewModel: ObservableObject {
    @Published var shoes: [ShoeInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedSortType: ShoeSortType = .fit

    private var currentPage: Int = 0
    private var hasNext: Bool = false

    func fetchShoes(page: Int = 0) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await ShoeAPI.shared.fetchShoes(
                sort: selectedSortType,
                page: page,
                size: 20
            )

            let mappedShoes = result.shoes.map { $0.toDomain() }

            if page == 0 {
                shoes = mappedShoes
            } else {
                shoes += mappedShoes
            }

            currentPage = result.currentPage
            hasNext = result.hasNext
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func reloadShoes() async {
        await fetchShoes(page: 0)
    }

    func loadNextPageIfNeeded(currentShoe: ShoeInfo) async {
        guard hasNext else { return }
        guard currentShoe.id == shoes.last?.id else { return }

        await fetchShoes(page: currentPage + 1)
    }
}
