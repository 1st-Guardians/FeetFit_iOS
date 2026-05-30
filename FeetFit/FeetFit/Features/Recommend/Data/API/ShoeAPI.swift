//
//  ShoeAPI.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import Foundation

final class ShoeAPI {
    static let shared = ShoeAPI()
    
    private init() {}
    
    func fetchShoes(
        sort: ShoeSortType,
        page: Int = 0,
        size: Int = 20
    ) async throws -> ShoeListResultDTO {
        var components = URLComponents(string: "https://서버주소/api/shoes")
        
        components?.queryItems = [
            URLQueryItem(name: "sort", value: sort.apiValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // 토큰 저장 위치에 맞게 수정
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if 200..<300 ~= httpResponse.statusCode {
            let decoded = try JSONDecoder().decode(ShoeListResponseDTO.self, from: data)
            return decoded.result
        } else {
            let decodedError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw ShoeAPIError.server(
                code: decodedError?.code ?? "UNKNOWN",
                message: decodedError?.message ?? "알 수 없는 오류가 발생했습니다."
            )
        }
    }
}

struct APIErrorResponse: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
}

enum ShoeAPIError: LocalizedError {
    case server(code: String, message: String)
    
    var errorDescription: String? {
        switch self {
        case .server(_, let message):
            return message
        }
    }
}
