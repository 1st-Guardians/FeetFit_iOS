//
//  StretchingTodoDTO.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation

struct StretchingTodoListResultDTO: Decodable {
    let totalCount: Int
    let hasTodayTodos: Bool
    let message: String
    let todos: [StretchingTodoDTO]
}

struct StretchingTodoDTO: Decodable {
    let todoId: Int
    let title: String
    let healthType: String
    let youtubeUrl: String
    let isCompleted: Bool
    let completedAt: String?
    let todoDate: String
}

extension StretchingTodoDTO {
    var toDomain: StretchingTodo {
        StretchingTodo(
            id: todoId,
            title: title,
            healthType: healthType,
            youtubeUrl: youtubeUrl,
            isCompleted: isCompleted,
            todoDate: todoDate
        )
    }
}
