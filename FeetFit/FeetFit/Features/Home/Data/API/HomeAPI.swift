//
//  HomeAPI.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Moya

final class HomeAPI {
    static let shared = HomeAPI()

    private let provider = APIManager.shared.createProvider(
        for: HomeRouter.self,
        withAuth: true
    )

    private init() {}

    func updateTodoCompletion(todoId: Int, isCompleted: Bool) async throws -> StretchingTodo {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.patchTodoCompletion(todoId: todoId, isCompleted: isCompleted)) { result in
                switch result {
                case .success(let response):
                    print("Todo Completion statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<StretchingTodoDTO>.self,
                            from: response.data
                        )

                        guard decoded.isSuccess else {
                            continuation.resume(
                                throwing: APIError.serverError(decoded.message)
                            )
                            return
                        }

                        guard let result = decoded.result else {
                            continuation.resume(
                                throwing: APIError.serverError("완료 처리 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result.toDomain)
                    } catch {
                        print("Todo Completion decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Todo Completion failure statusCode:", response.statusCode)

                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponse.self,
                            from: response.data
                        )

                        if response.statusCode == 401 {
                            continuation.resume(throwing: APIError.unauthorized)
                            return
                        }

                        continuation.resume(
                            throwing: APIError.serverError(
                                errorResponse?.message ?? "알 수 없는 오류가 발생했습니다."
                            )
                        )
                        return
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }

    func fetchArticles() async throws -> [HealthNews] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getArticles) { result in
                switch result {
                case .success(let response):
                    print("Articles statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<ArticleListResultDTO>.self,
                            from: response.data
                        )

                        guard decoded.isSuccess else {
                            continuation.resume(
                                throwing: APIError.serverError(decoded.message)
                            )
                            return
                        }

                        guard let result = decoded.result else {
                            continuation.resume(
                                throwing: APIError.serverError("아티클 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result.articles.map { $0.toDomain })
                    } catch {
                        print("Articles decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Articles failure statusCode:", response.statusCode)

                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponse.self,
                            from: response.data
                        )

                        if response.statusCode == 401 {
                            continuation.resume(throwing: APIError.unauthorized)
                            return
                        }

                        continuation.resume(
                            throwing: APIError.serverError(
                                errorResponse?.message ?? "알 수 없는 오류가 발생했습니다."
                            )
                        )
                        return
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }

    func fetchStretchingTodos() async throws -> [StretchingTodo] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.getStretchingTodos) { result in
                switch result {
                case .success(let response):
                    print("Stretching Todos statusCode:", response.statusCode)

                    do {
                        let decoded = try JSONDecoder().decode(
                            BaseResponse<StretchingTodoListResultDTO>.self,
                            from: response.data
                        )

                        guard decoded.isSuccess else {
                            continuation.resume(
                                throwing: APIError.serverError(decoded.message)
                            )
                            return
                        }

                        guard let result = decoded.result else {
                            continuation.resume(
                                throwing: APIError.serverError("스트레칭 TODO 응답이 비어 있습니다.")
                            )
                            return
                        }

                        continuation.resume(returning: result.todos.map { $0.toDomain })
                    } catch {
                        print("Stretching Todos decoding error:", error)
                        continuation.resume(throwing: APIError.decodingError)
                    }

                case .failure(let error):
                    if let response = error.response {
                        print("Stretching Todos failure statusCode:", response.statusCode)

                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponse.self,
                            from: response.data
                        )

                        if response.statusCode == 401 {
                            continuation.resume(throwing: APIError.unauthorized)
                            return
                        }

                        continuation.resume(
                            throwing: APIError.serverError(
                                errorResponse?.message ?? "알 수 없는 오류가 발생했습니다."
                            )
                        )
                        return
                    }

                    continuation.resume(throwing: APIError.from(error))
                }
            }
        }
    }
}
