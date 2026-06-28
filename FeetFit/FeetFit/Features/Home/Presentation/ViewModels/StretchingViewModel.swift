//
//  StretchingViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Combine

@MainActor
final class StretchingViewModel: ObservableObject {
    @Published var todos: [StretchingTodo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchTodos() async {
        isLoading = true
        errorMessage = nil

        do {
            todos = try await HomeAPI.shared.fetchStretchingTodos()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
