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

    func toggleCompletion(at index: Int) {
        let todoId = todos[index].id
        let previousIsCompleted = todos[index].isCompleted
        let newIsCompleted = !previousIsCompleted

        todos[index].isCompleted = newIsCompleted

        Task {
            do {
                let updated = try await HomeAPI.shared.updateTodoCompletion(
                    todoId: todoId,
                    isCompleted: newIsCompleted
                )
                if let idx = todos.firstIndex(where: { $0.id == todoId }) {
                    todos[idx] = updated
                }
            } catch {
                if let idx = todos.firstIndex(where: { $0.id == todoId }) {
                    todos[idx].isCompleted = previousIsCompleted
                }
                errorMessage = error.localizedDescription
            }
        }
    }
}
