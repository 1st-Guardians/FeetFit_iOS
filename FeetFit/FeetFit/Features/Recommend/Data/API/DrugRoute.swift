import Foundation
import Moya
import Alamofire

enum DrugRoute {
    case getDrugs(category: DrugCategory, query: String, page: Int, size: Int)
    case getDrugPermit(itemSeq: String)
}

extension DrugRoute: APITargetType {
    var path: String {
        switch self {
        case .getDrugs: return APIConfig.Path.drugs
        case .getDrugPermit: return "\(APIConfig.Path.drugs)/permit"
        }
    }

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
        case .getDrugPermit(let itemSeq):
            return .requestParameters(parameters: ["itemSeq": itemSeq], encoding: URLEncoding.queryString)
        }
    }
}
