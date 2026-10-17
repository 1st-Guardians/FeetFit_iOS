#!/usr/bin/env python3
"""Check the production drug router, DTO mapping, and list state with local network I/O."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1] / "FeetFit/FeetFit"
files = [
    "Core/Enum/DrugCategory.swift",
    "Core/Network/APIConfig.swift",
    "Core/Network/BaseResponse.swift",
    "Core/Network/APIErrorResponse.swift",
    "Features/Recommend/Domain/Models/ProductInfo.swift",
    "Features/Recommend/Data/API/DrugRoute.swift",
    "Features/Recommend/Data/DTO/DrugDTO.swift",
    "Features/Recommend/Presentation/ViewModels/DrugListViewModel.swift",
]
production = "\n".join(
    (root / name).read_text().replace("import Moya", "").replace("import Alamofire", "")
    for name in files
)
harness = r'''
enum Moya {
    enum Method { case get }
    typealias Cancellable = StubCancellable
}
enum URLEncoding { case queryString }
enum Task { case requestParameters(parameters: [String: Any], encoding: URLEncoding) }
protocol APITargetType {}
protocol StubCancellable { func cancel() }
final class StubRequest: Moya.Cancellable {
    var cancelled = false
    func cancel() { cancelled = true }
}
struct Response { let data: Data }
struct RequestError: Error { var response: Response? }
enum APIError: Error, LocalizedError {
    case serverError(String)
    var errorDescription: String? {
        switch self { case .serverError(let message): return message }
    }
}
final class DrugProvider {
    struct Pending {
        let route: DrugRoute
        let token: StubRequest
        let completion: (Result<Response, RequestError>) -> Void
    }
    var pending: [Pending] = []
    func request(_ route: DrugRoute, completion: @escaping (Result<Response, RequestError>) -> Void) -> Moya.Cancellable {
        let token = StubRequest()
        pending.append(Pending(route: route, token: token, completion: completion))
        return token
    }
    func complete(_ index: Int, json: String, failed: Bool = false) {
        let response = Response(data: Data(json.utf8))
        pending[index].completion(failed ? .failure(RequestError(response: response)) : .success(response))
    }
}
struct APIManager {
    static let shared = APIManager()
    let provider = DrugProvider()
    func createProvider(for type: DrugRoute.Type, withAuth: Bool) -> DrugProvider {
        assert(withAuth, "Keep the existing authenticated provider")
        return provider
    }
}
@MainActor final class ToastManager {
    static let shared = ToastManager()
    var message = ""
    func show(_ message: String) { self.message = message }
}

@main struct Check {
    static let medicine = #"{"id":"199304286","name":"라미실크림1%(테르비나핀염산염)","company":"지피테라퓨틱스코리아주식회사","image":"https://example.com/drug.jpg","efficacy":"효능 원문","usage":"사용법 원문","warning":"주의사항 원문","interaction":" ","sideEffect":"부작용 원문","storage":"실온에서 보관하십시오.","priceHint":null,"detailUrl":null,"description":null,"checklist":null,"online":false,"permit":{"itemSeq":"199304286","englishName":"Lamisil Cream 1%","classification":"일반의약품","status":"허가 정상","cancelled":false,"permitDate":"1993.04.07","permitType":"신고","appearance":"백색의 크림제","mainIngredient":"테르비나핀염산염","packUnit":"15g/튜브, 30g/튜브","storage":"실온보관, 기밀용기","validTerm":"제조일로부터 36 개월","atcCode":"D01AE15","officialUrl":"https://nedrug.mfds.go.kr/pbp/CCBBB01/getItemDetail?itemSeq=199304286"}}"#
    static let band = #"{"id":"band-1","name":"교정밴드","company":null,"image":null,"efficacy":"","description":"제품 설명","interaction":"함께 사용 시 확인","detailUrl":"https://example.com/band","permit":null}"#
    static func page(_ items: [String], number: Int = 0, next: Bool = false, total: Int = 69) -> String {
        """
        {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"category":"athletes-foot","categoryLabel":"무좀약","source":"식품의약품안전처 e약은요","items":[\(items.joined(separator: ","))],"currentPage":\(number),"totalPages":4,"totalElements":\(total),"hasNext":\(next)}}
        """
    }
    static func parameters(_ route: DrugRoute) -> [String: Any] {
        assert(route.path == "/api/drugs" && route.method == .get)
        guard case let .requestParameters(parameters, encoding) = route.task else { fatalError() }
        assert(encoding == .queryString)
        return parameters
    }
    static func drain() async { try! await _Concurrency.Task.sleep(for: .milliseconds(10)) }

    @MainActor static func main() async throws {
        for category in DrugCategory.allCases {
            let params = parameters(.getDrugs(category: category, query: " ", page: 0, size: 20))
            assert(params["category"] as? String == category.rawValue)
            assert(params["page"] as? Int == 0 && params["size"] as? Int == 20)
            assert(params["query"] == nil)
        }
        let mapped = try JSONDecoder().decode(DrugDTO.self, from: Data(medicine.utf8))
            .toDomain(categoryLabel: "무좀약", source: "식품의약품안전처 e약은요")
        assert(mapped.id == "199304286" && mapped.tag == "무좀약")
        assert(mapped.effects == "효능 원문" && mapped.usage == "사용법 원문")
        assert(mapped.precautions == "주의사항 원문" && mapped.sideEffects == "부작용 원문")
        assert(mapped.interactions == nil && mapped.storage == "실온에서 보관하십시오.")
        assert(mapped.officialURL?.query == "itemSeq=199304286" && mapped.detailItems.count == 12)
        assert(mapped.informationSource == "식품의약품안전처 e약은요")
        let nullable = try JSONDecoder().decode(DrugDTO.self, from: Data(band.utf8))
            .toDomain(categoryLabel: "무지외반증 교정밴드", source: "제품 정보")
        assert(nullable.id == "band-1" && nullable.effects == "제품 설명")
        assert(nullable.imageURL.isEmpty && nullable.detailItems.isEmpty)
        assert(nullable.officialURL?.absoluteString == "https://example.com/band")
        assert(nullable.interactions == "함께 사용 시 확인")

        let vm = DrugListViewModel()
        let provider = APIManager.shared.provider
        vm.fetchInitialData()
        vm.fetchInitialData()
        assert(provider.pending.count == 1 && vm.isLoading)
        provider.complete(0, json: page([medicine], next: true))
        await drain()
        assert(vm.products.count == 1 && vm.totalElements == 69 && !vm.isLoading)
        vm.loadNextPageIfNeeded(currentProduct: mapped)
        vm.loadNextPageIfNeeded(currentProduct: mapped)
        assert(provider.pending.count == 2 && parameters(provider.pending[1].route)["page"] as? Int == 1)
        provider.complete(1, json: #"{"isSuccess":false,"code":"ERR","message":"잠시 후 시도하세요"}"#, failed: true)
        await drain()
        assert(vm.products.count == 1 && vm.errorMessage == "잠시 후 시도하세요")
        vm.loadNextPageIfNeeded(currentProduct: mapped)
        assert(provider.pending.count == 2, "A failed page waits for explicit retry")
        vm.retry()
        assert(parameters(provider.pending[2].route)["page"] as? Int == 1)
        provider.complete(2, json: page([band], number: 1))
        await drain()
        assert(vm.products.map(\.id) == ["199304286", "band-1"] && vm.errorMessage == nil)
        vm.loadNextPageIfNeeded(currentProduct: vm.products.last!)
        assert(provider.pending.count == 3, "hasNext=false ends pagination")

        vm.search(query: "  라미실  ")
        assert(vm.products.isEmpty && vm.totalElements == 0)
        assert(parameters(provider.pending[3].route)["query"] as? String == "라미실")
        vm.updateCategory(.bunionBand)
        assert(provider.pending[3].token.cancelled)
        assert(parameters(provider.pending[4].route)["category"] as? String == "bunion-band")
        provider.complete(3, json: page([medicine]))
        await drain()
        assert(vm.products.isEmpty && vm.isLoading, "Ignore the old category response")
        provider.complete(4, json: page([band], total: 1))
        await drain()
        assert(vm.products.first?.id == "band-1" && !vm.isLoading)
        vm.search(query: "")
        assert(parameters(provider.pending[5].route)["query"] == nil)
        provider.complete(5, json: page([], total: 0))
        await drain()
        assert(vm.products.isEmpty && vm.totalElements == 0 && vm.errorMessage == nil)

        for (json, message) in [
            (#"{"isSuccess":false,"code":"ERR","message":"조회 실패","result":null}"#, "조회 실패"),
            (#"{"isSuccess":true,"code":"COMMON200","message":"성공","result":null}"#, "제품 목록 응답이 비어 있습니다."),
            ("invalid JSON", "제품 목록을 처리하지 못했습니다.")
        ] {
            vm.retry()
            provider.complete(provider.pending.count - 1, json: json)
            await drain()
            assert(vm.errorMessage == message && !vm.isLoading && ToastManager.shared.message == message)
        }
        vm.retry()
        provider.pending.last!.completion(.failure(RequestError(response: nil)))
        await drain()
        assert(vm.errorMessage == "제품 목록을 불러오지 못했습니다.")
        print("PASS: drug categories/query, nullable DTO/detail mapping, pagination/retry, stale responses, and API errors")
    }
}
'''

with tempfile.TemporaryDirectory(prefix="feetfit-drug-check-") as directory:
    work = Path(directory)
    source = work / "check.swift"
    source.write_text(production + "\n" + harness)
    env = os.environ | {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"}
    subprocess.run(["xcrun", "swiftc", "-parse-as-library", "-module-cache-path", str(work / "cache"), str(source), "-o", str(work / "check")], env=env, check=True)
    subprocess.run([str(work / "check")], check=True)
