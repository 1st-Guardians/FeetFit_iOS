import Foundation
import Moya
import Alamofire

enum DrugRoute {
    case getDrugs(category: DrugCategory, query: String, page: Int, size: Int)
}

extension DrugRoute: APITargetType {
    var path: String { APIConfig.Path.drugs }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case .getDrugs(let category, let query, let page, let size):
            var parameters: [String: Any] = [
                "category": category.rawValue,
                "page": page,
                "size": size
            ]
            let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if !keyword.isEmpty {
                parameters["query"] = keyword
            }
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
