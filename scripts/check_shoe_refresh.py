#!/usr/bin/env python3
"""Check nickname, foot-type text, and shoe refresh using the production view model."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1] / "FeetFit/FeetFit"
files = [
    "Core/Enum/ShoeSortType.swift",
    "Core/Network/BaseResponse.swift",
    "Core/Network/APIErrorResponse.swift",
    "Features/Recommend/Domain/Models/ShoeInfo.swift",
    "Features/Recommend/Data/API/ShoeRoute.swift",
    "Features/Recommend/Data/DTO/ShoeDTO.swift",
    "Features/Recommend/Data/DTO/ShoeRecommendationDTO.swift",
    "Features/Recommend/Data/DTO/ShoeSearchDTO.swift",
    "Features/Recommend/Data/DTO/ShoeSearchHistoryDTO.swift",
    "Features/Recommend/Data/DTO/FootTypeTextDTO.swift",
    "Features/Recommend/Data/DTO/EmptyResultDTO.swift",
    "Features/Recommend/Presentation/ViewModels/RecommendListViewModel.swift",
]
production = "\n".join(
    (root / name).read_text().replace("import Moya", "").replace("import Alamofire", "")
    for name in files
)
harness = r'''
enum Moya { enum Method { case get, post, delete } }
enum URLEncoding { case queryString }
enum Task { case requestPlain, requestParameters(parameters: [String: Any], encoding: URLEncoding) }
protocol APITargetType {}
struct Response { let data: Data; let statusCode = 200 }
struct RequestError: Error { var response: Response? }
final class ShoeProvider {
    var nickname = "이전 이름"
    var typeText: String? = "이전 발 타입"
    var shoeID = 1
    var failFootType = false
    var footTypeRequestCount = 0
    var listRequests: [(sort: ShoeSortType, page: Int)] = []

    func request(_ route: ShoeRoute, completion: (Result<Response, RequestError>) -> Void) {
        let result: [String: Any]
        switch route {
        case .getFootTypeText:
            footTypeRequestCount += 1
            if failFootType {
                completion(.failure(RequestError(response: nil)))
                return
            }
            result = ["nickname": nickname, "typeText": typeText as Any? ?? NSNull()]
        case .getShoes(let sort, let page, _):
            listRequests.append((sort, page))
            result = [
                "shoes": [["id": shoeID, "brandName": "브랜드", "shoeName": "신발",
                           "price": 10000, "imageUrl": "", "overallRating": 4.5]],
                "currentPage": page, "totalPages": 1, "totalElements": 1, "hasNext": false
            ]
        case .getTopRecommendations:
            result = ["shoes": []]
        case .getSearchHistory:
            result = ["histories": []]
        default:
            fatalError("Unexpected route in refresh check")
        }
        let data = try! JSONSerialization.data(withJSONObject: [
            "isSuccess": true, "code": "COMMON200", "message": "성공", "result": result
        ])
        completion(.success(Response(data: data)))
    }
}
struct APIManager {
    static let shared = APIManager()
    let provider = ShoeProvider()
    func createProvider(for type: ShoeRoute.Type, withAuth: Bool) -> ShoeProvider {
        assert(withAuth)
        return provider
    }
}
@MainActor final class ToastManager {
    static let shared = ToastManager()
    func show(_ message: String) {}
}
@main struct Check {
    static func drain() async { try! await _Concurrency.Task.sleep(for: .milliseconds(20)) }
    @MainActor static func main() async {
        let provider = APIManager.shared.provider
        let vm = RecommendListViewModel()
        vm.fetchInitialData()
        await drain()
        assert(vm.nickname == "이전 이름" && vm.footTypeText == "이전 발 타입")
        assert(vm.shoes.map(\.id) == [1] && vm.selectedSortType == .fit)

        vm.updateSortType(.click)
        await drain()
        provider.nickname = "변경한 이름"
        provider.typeText = "새 측정의 발 타입"
        provider.shoeID = 2
        vm.fetchInitialData()
        await drain()
        assert(provider.footTypeRequestCount == 2, "Re-entry must request the header again")
        assert(vm.nickname == "변경한 이름" && vm.footTypeText == "새 측정의 발 타입")
        assert(vm.shoes.map(\.id) == [2], "Refresh replaces the old shoe list")
        assert(provider.listRequests.count == 3 && provider.listRequests.last!.page == 0)
        assert(vm.selectedSortType == .click, "Refresh preserves the user's sort selection")

        vm.updateSortType(.fit)
        await drain()
        provider.typeText = nil
        vm.fetchInitialData()
        await drain()
        assert(provider.footTypeRequestCount == 3 && vm.footTypeText == nil)
        assert(vm.selectedSortType == .rating, "Without a measurement, use rating instead of fit")

        provider.failFootType = true
        vm.fetchInitialData()
        await drain()
        provider.failFootType = false
        provider.nickname = "재시도 이름"
        provider.typeText = "재시도 발 타입"
        provider.shoeID = 3
        vm.fetchInitialData()
        await drain()
        assert(provider.footTypeRequestCount == 5, "A failed refresh must not prevent the next entry from retrying")
        assert(vm.nickname == "재시도 이름" && vm.footTypeText == "재시도 발 타입")
        assert(vm.shoes.map(\.id) == [3] && !vm.isLoading)
        print("PASS: recommendation re-entry refreshes nickname, foot type, and shoes; preserves sorting; retries after failure")
    }
}
'''
with tempfile.TemporaryDirectory(prefix="feetfit-shoe-refresh-check-") as directory:
    work = Path(directory)
    source = work / "check.swift"
    source.write_text(production + "\n" + harness)
    env = os.environ | {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"}
    subprocess.run(["xcrun", "swiftc", "-parse-as-library", "-module-cache-path", str(work / "cache"), str(source), "-o", str(work / "check")], env=env, check=True)
    result = subprocess.run([str(work / "check")], capture_output=True, text=True)
    if result.returncode:
        print(result.stdout)
        print(result.stderr)
        raise SystemExit(result.returncode)
    print(result.stdout.splitlines()[-1])
