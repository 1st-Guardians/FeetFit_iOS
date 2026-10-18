#!/usr/bin/env python3
"""Check the production drug routes, DTO mapping, and list/detail state without network I/O."""
from pathlib import Path
import os
import plistlib
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
    "Features/Recommend/Presentation/ViewModels/DrugDetailViewModel.swift",
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
    static let detail = #"{"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"drug":{"id":"199400709","name":"영진멘탁스크림(부테나핀염산염)","company":"영진약품(주)","image":"/drug-images/199400709.jpg","efficacy":"백선, 어루러기에 사용합니다.","usage":"1일 1회 환부에 바릅니다.","warning":"이 약은 외용으로만 사용하십시오.","interaction":"","sideEffect":"자극 시 사용을 중지하십시오.","storage":"습기와 빛을 피해 실온에서 보관하십시오.","category":"athletes-foot","online":false,"priceHint":null,"detailUrl":null,"description":null,"checklist":null,"permit":null},"permit":{"itemSeq":"199400709","englishName":"Yungjin Mentax Cream(20g)","classification":"일반의약품","status":"허가 정상","cancelled":false,"permitDate":"1994.01.17","permitType":"신고","appearance":"백색의 크림으로 약간 특이한 냄새가 있다","mainIngredient":"부테나핀염산염","packUnit":"10g/tube, 20g/tube, 450g/병","storage":"차광,기밀용기, 실온보관","validTerm":"제조일로부터 32 개월","atcCode":"D01AE23","officialUrl":"https://nedrug.mfds.go.kr/pbp/CCBBB01/getItemDetail?itemSeq=199400709"},"recall":{"status":"clear","records":[],"checkedAt":"2026-10-12T06:21:02.207865Z","sourceUrl":"https://www.data.go.kr/data/15059114/openapi.do"},"source":"식품의약품안전처 e약은요 + 식품의약품안전처 의약품 제품 허가정보"}}"#
    static func page(_ items: [String], number: Int = 0, next: Bool = false, total: Int = 69) -> String {
        """
        {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"category":"athletes-foot","categoryLabel":"무좀약","source":"식품의약품안전처 e약은요","items":[\(items.joined(separator: ","))],"currentPage":\(number),"totalPages":4,"totalElements":\(total),"hasNext":\(next)}}
        """
    }
    static let recommendationSummary = "무좀 관련 안전점수가 낮아 해당 부위의 관리를 우선 살필 수 있도록 무좀약 정보를 먼저 안내합니다. 실제 제품 사용 전에는 제품 설명서를 확인하고 약사와 상담해 주세요."
    static let priorities = #"[{"rank":3,"category":"wound-care"},{"rank":1,"category":"bunion-band"},{"rank":2,"category":"athletes-foot"}]"#
    static func recommendationPage(_ items: [String], priorities: String = priorities, hasMeasurement: Bool = true, summary: String? = recommendationSummary, number: Int = 0, next: Bool = false) -> String {
        let summaryJSON = summary.map { String(decoding: try! JSONEncoder().encode($0), as: UTF8.self) } ?? "null"
        return """
        {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"hasMeasurement":\(hasMeasurement),"reportId":\(hasMeasurement ? "8" : "null"),"summary":\(summaryJSON),"summaryStatus":"COMPLETED","summarySource":"GPT","priorities":\(priorities),"items":[\(items.joined(separator: ","))],"currentPage":\(number),"totalPages":2,"totalElements":4,"hasNext":\(next)}}
        """
    }
    static func parameters(_ route: DrugRoute) -> [String: Any] {
        assert(route.method == .get)
        switch route {
        case .getDrugs: assert(route.path == "/api/drugs/recommendations")
        case .getDrugPermit: assert(route.path == "/api/drugs/permit")
        }
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
            assert(params["q"] == nil)
        }
        let allParameters = parameters(.getDrugs(category: nil, query: "  관리  ", page: 0, size: 20))
        assert(allParameters["category"] == nil && allParameters["q"] as? String == "관리")
        assert(allParameters["query"] == nil, "The recommendation endpoint searches with q")
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
        assert(mapped.itemSeq == "199304286" && nullable.itemSeq == nil)

        let detailResult = try JSONDecoder().decode(BaseResponse<DrugDetailResultDTO>.self, from: Data(detail.utf8)).result!
        let detailed = detailResult.toDomain(categoryLabel: "무좀약")
        assert(detailed.id == "199400709" && detailed.itemSeq == "199400709")
        assert(detailed.tags == ["무좀약", "일반의약품"])
        assert(detailed.name == "영진멘탁스크림(부테나핀염산염)" && detailed.brand == "영진약품(주)")
        assert(detailed.imageURL == "https://api.example.test/drug-images/199400709.jpg")
        assert(detailed.officialURL?.query == "itemSeq=199400709")
        assert(detailed.detailItems.contains(.init(title: "주성분", value: "부테나핀염산염")))
        assert(detailed.detailItems.contains(.init(title: "허가일", value: "1994.01.17")))
        assert(detailed.detailItems.contains(.init(title: "회수 조회 결과", value: "회수 이력 없음")))
        assert(detailed.detailItems.contains { $0.title == "회수 조회 시각" })
        assert(detailed.recallSourceURL?.host == "www.data.go.kr")
        assert(detailed.informationSource == detailResult.source && detailed.interactions == nil)
        assert(detailed.storage == "습기와 빛을 피해 실온에서 보관하십시오.")
        assert(detailed.precautions == "이 약은 외용으로만 사용하십시오.")
        assert(detailed.sideEffects == "자극 시 사용을 중지하십시오.")
        let noPermitJSON = #"{"drug":{"id":"199400709","name":"의약품","storage":null,"permit":null},"permit":null,"recall":null,"source":"식약처"}"#
        let noPermit = try JSONDecoder().decode(DrugDetailResultDTO.self, from: Data(noPermitJSON.utf8))
            .toDomain(categoryLabel: "무좀약")
        assert(noPermit.itemSeq == "199400709" && noPermit.detailItems.isEmpty && noPermit.officialURL == nil)
        assert(noPermit.tags == ["무좀약"])
        let partialPermitJSON = #"{"drug":{"id":"199400709","name":"의약품","storage":" ","permit":null},"permit":{"cancelled":true,"storage":"실온보관"},"recall":{"status":"unknown","checkedAt":"2026-10-12T06:21:02Z"},"source":"식약처"}"#
        let partial = try JSONDecoder().decode(DrugDetailResultDTO.self, from: Data(partialPermitJSON.utf8))
            .toDomain(categoryLabel: "무좀약")
        assert(partial.storage == "실온보관")
        assert(partial.detailItems.contains(.init(title: "허가 상태", value: "허가 취소")))
        assert(partial.detailItems.contains(.init(title: "회수 조회 결과", value: "공식 정보 확인 필요")))
        assert(partial.detailItems.contains { $0.title == "회수 조회 시각" })

        let vm = DrugListViewModel()
        let provider = APIManager.shared.provider
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
        assert(parameters(provider.pending[3].route)["q"] as? String == "라미실")
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
        assert(parameters(provider.pending[5].route)["q"] == nil)
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

        let taggedBand = band.replacingOccurrences(of: #""permit":null"#, with: #""category":"bunion-band","permit":null"#)
        let secondBand = taggedBand.replacingOccurrences(of: "band-1", with: "band-2")
        let taggedMedicine = medicine.replacingOccurrences(of: #""permit":{"#, with: #""category":"athletes-foot","permit":{"#)
        let secondMedicine = taggedMedicine.replacingOccurrences(of: "199304286", with: "199304287")
        let wound = #"{"id":"wound-1","name":"상처 관리 제품","category":"wound-care"}"#
        let recommendationResult = try JSONDecoder().decode(BaseResponse<DrugListResultDTO>.self, from: Data(recommendationPage([taggedBand]).utf8)).result!
        assert(recommendationResult.hasMeasurement == true && recommendationResult.reportId == 8)
        assert(recommendationResult.summary == recommendationSummary)
        assert(recommendationResult.summaryStatus == "COMPLETED" && recommendationResult.summarySource == "GPT")
        assert(recommendationResult.categoryLabel == nil && recommendationResult.source == nil, "The new contract omits legacy result-level labels/source")
        assert(recommendationResult.orderedCategories == [.bunionBand, .athletesFoot, .woundCare])
        let messyPriorities = #"[{"rank":0,"category":"wound-care"},{"rank":1,"category":"future-category"},{"rank":2,"category":"bunion-band"},{"rank":3,"category":"bunion-band"}]"#
        let messy = try JSONDecoder().decode(BaseResponse<DrugListResultDTO>.self, from: Data(recommendationPage([], priorities: messyPriorities).utf8)).result!
        assert(messy.orderedCategories == [.bunionBand, .athletesFoot, .woundCare], "Ignore unknown/duplicate priorities and keep unranked categories available")

        let recommendedVM = DrugListViewModel()
        var index = provider.pending.count
        recommendedVM.fetchInitialData()
        assert(parameters(provider.pending[index].route)["category"] as? String == "athletes-foot")
        provider.complete(index, json: recommendationPage([secondBand, taggedMedicine, wound, taggedBand], next: true))
        await drain()
        assert(recommendedVM.selectedCategory == .bunionBand && recommendedVM.orderedCategories == [.bunionBand, .athletesFoot, .woundCare])
        assert(recommendedVM.recommendationSummary == recommendationSummary && recommendedVM.hasMeasurement == true)
        assert(provider.pending.count == index + 2 && recommendedVM.isLoading && recommendedVM.products.isEmpty)
        assert(parameters(provider.pending.last!.route)["category"] as? String == "bunion-band")
        provider.complete(index + 1, json: recommendationPage([secondBand, taggedMedicine, wound, taggedBand], next: true))
        await drain()
        assert(recommendedVM.products.map(\.id) == ["band-2", "band-1", "199304286", "wound-1"], "Group all products by rank, keeping item order inside each category")
        assert(recommendedVM.products.map(\.tag) == ["무지외반증 교정밴드", "무지외반증 교정밴드", "무좀약", "상처·발 관리"])
        recommendedVM.loadNextPageIfNeeded(currentProduct: recommendedVM.products.last!)
        assert(parameters(provider.pending.last!.route)["page"] as? Int == 1)
        provider.complete(provider.pending.count - 1, json: page([secondMedicine, taggedBand.replacingOccurrences(of: "band-1", with: "band-3")], number: 1))
        await drain()
        assert(recommendedVM.products.map(\.id) == ["band-2", "band-1", "band-3", "199304286", "199304287", "wound-1"], "Pagination must keep rank ordering across all loaded pages")
        assert(recommendedVM.recommendationSummary == recommendationSummary, "Pagination without recommendation metadata keeps the current header")

        index = provider.pending.count
        recommendedVM.updateCategory(.woundCare)
        provider.complete(index, json: recommendationPage([wound]))
        await drain()
        assert(provider.pending.count == index + 1 && recommendedVM.selectedCategory == .woundCare, "Priority updates must not undo the user's selection")
        assert(recommendedVM.products.first?.tag == "상처·발 관리")
        recommendedVM.search(query: "  관리  ")
        assert(parameters(provider.pending.last!.route)["q"] as? String == "관리")
        assert(parameters(provider.pending.last!.route)["category"] as? String == "wound-care")
        provider.complete(provider.pending.count - 1, json: recommendationPage([], summary: "  "))
        await drain()
        assert(recommendedVM.recommendationSummary.contains("제품 추천 안내를 준비"))

        let specifiedPriorities = #"[{"rank":1,"category":"athletes-foot"},{"rank":2,"category":"bunion-band"},{"rank":3,"category":"wound-care"}]"#
        recommendedVM.updateCategory(.athletesFoot)
        assert(parameters(provider.pending.last!.route)["category"] as? String == "athletes-foot")
        provider.complete(provider.pending.count - 1, json: recommendationPage([wound, taggedBand, taggedMedicine], priorities: specifiedPriorities))
        await drain()
        assert(recommendedVM.orderedCategories == [.athletesFoot, .bunionBand, .woundCare])
        assert(recommendedVM.products.map(\.id) == ["199304286", "band-1", "wound-1"], "Match the supplied priorities even when items arrive in the reverse category order")

        let earlySelectionVM = DrugListViewModel()
        index = provider.pending.count
        earlySelectionVM.fetchInitialData()
        earlySelectionVM.updateCategory(.woundCare)
        assert(provider.pending[index].token.cancelled)
        provider.complete(index, json: recommendationPage([medicine]))
        provider.complete(index + 1, json: recommendationPage([wound]))
        await drain()
        assert(provider.pending.count == index + 2 && earlySelectionVM.selectedCategory == .woundCare)
        assert(earlySelectionVM.products.first?.id == "wound-1")

        let noMeasurementVM = DrugListViewModel()
        noMeasurementVM.fetchInitialData()
        provider.complete(provider.pending.count - 1, json: recommendationPage([], priorities: "[]", hasMeasurement: false, summary: nil))
        await drain()
        assert(noMeasurementVM.hasMeasurement == false && noMeasurementVM.orderedCategories == DrugCategory.allCases)
        assert(noMeasurementVM.recommendationSummary.contains("발을 측정하면"))

        index = provider.pending.count
        recommendedVM.fetchInitialData()
        assert(provider.pending.count == index + 1 && recommendedVM.isLoading && recommendedVM.products.isEmpty,
               "Re-entering recommendations must fetch products again from page zero")
        let refreshParameters = parameters(provider.pending[index].route)
        assert(refreshParameters["page"] as? Int == 0 && refreshParameters["category"] as? String == "athletes-foot")
        assert(refreshParameters["q"] as? String == "관리", "Refresh keeps the selected category and search query")
        provider.complete(index, json: recommendationPage([taggedMedicine], priorities: specifiedPriorities, summary: "새 측정 결과에 맞춘 안내"))
        await drain()
        assert(recommendedVM.products.map(\.id) == ["199304286"] && !recommendedVM.isLoading)
        assert(recommendedVM.recommendationSummary == "새 측정 결과에 맞춘 안내", "Refresh updates the product header too")

        let detailStart = provider.pending.count
        let bandDetail = DrugDetailViewModel(product: nullable)
        bandDetail.fetchDetail()
        assert(provider.pending.count == detailStart && !bandDetail.isLoading, "Non-drug products keep their existing detail screen")
        let detailVM = DrugDetailViewModel(product: noPermit)
        detailVM.fetchDetail()
        detailVM.fetchDetail()
        assert(provider.pending.count == detailStart + 1 && detailVM.isLoading)
        let params = parameters(provider.pending.last!.route)
        assert(params.count == 1 && params["itemSeq"] as? String == "199400709")
        for (json, failed, message) in [
            (#"{"isSuccess":false,"code":"DRUG4001","message":"약 정보를 찾을 수 없습니다."}"#, true, "약 정보를 찾을 수 없습니다."),
            (#"{"isSuccess":false,"code":"ERR","message":"조회 실패","result":null}"#, false, "조회 실패"),
            (#"{"isSuccess":true,"code":"COMMON200","message":"성공","result":null}"#, false, "약 상세 응답이 비어 있습니다."),
            ("invalid JSON", false, "약 상세 정보를 처리하지 못했습니다.")
        ] {
            provider.complete(provider.pending.count - 1, json: json, failed: failed)
            await drain()
            assert(detailVM.errorMessage == message && !detailVM.isLoading && ToastManager.shared.message == message)
            assert(detailVM.product == noPermit, "A failed response does not overwrite the selected product")
            detailVM.fetchDetail()
            assert(detailVM.isLoading && detailVM.errorMessage == nil)
        }
        provider.pending.last!.completion(.failure(RequestError(response: nil)))
        await drain()
        assert(detailVM.errorMessage == "약 상세 정보를 불러오지 못했습니다.")
        detailVM.fetchDetail()
        provider.complete(provider.pending.count - 1, json: detail)
        await drain()
        assert(detailVM.product == detailed && detailVM.errorMessage == nil && !detailVM.isLoading)
        let countAfterDetail = provider.pending.count
        detailVM.fetchDetail()
        assert(provider.pending.count == countAfterDetail, "A loaded detail does not refetch when returning from a sheet")
        print("PASS: recommendation endpoint/q, all-category rank ordering across pages, category filters, summary, detail mapping, and API errors")
    }
}
'''

with tempfile.TemporaryDirectory(prefix="feetfit-drug-check-") as directory:
    work = Path(directory)
    source = work / "check.swift"
    source.write_text(production + "\n" + harness)
    info = work / "Info.plist"
    info.write_bytes(plistlib.dumps({"API_BASE_URL": "https://api.example.test"}))
    env = os.environ | {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"}
    subprocess.run(["xcrun", "swiftc", "-parse-as-library", "-module-cache-path", str(work / "cache"), str(source), "-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", str(info), "-o", str(work / "check")], env=env, check=True)
    subprocess.run([str(work / "check")], check=True)
