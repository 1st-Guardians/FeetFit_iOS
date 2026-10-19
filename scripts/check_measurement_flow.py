#!/usr/bin/env python3
"""Run the production measurement state/DTO/router/view-model code with local I/O stubs."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1] / "FeetFit/FeetFit"
files = [
    "Core/Enum/MeasurementStatus.swift",
    "Core/Enum/MeasurementFailureReason.swift",
    "Features/Measurement/Presentation/Models/MeasurementGuide.swift",
    "Features/Measurement/Data/DTO/MeasurementSessionDTO.swift",
    "Features/Measurement/Data/DTO/MeasurementSocketMessageDTO.swift",
    "Features/Measurement/Data/API/MeasurementRouter.swift",
    "Features/Measurement/Presentation/ViewModels/FootMeasurementViewModel.swift",
]
production = "\n".join(
    (root / name).read_text().replace("import Moya", "").replace("import Alamofire", "")
    for name in files
)
harness = r'''
import Foundation
import Observation

// Only network/platform dependencies are replaced; measurement logic is production code.
enum Moya { enum Method { case get, post, patch } }
enum URLEncoding { case queryString }
enum Task { case requestPlain, requestParameters(parameters: [String: Any], encoding: URLEncoding) }
protocol APITargetType {}
enum MyPageRouter { case getProfile }
struct MyPageProfileResult: Decodable { let userId: Int }
struct BaseResponse<T: Decodable>: Decodable { let result: T? }
struct Response { let data: Data }
struct ProfileProvider {
    func request(_ route: MyPageRouter, completion: (Result<Response, Error>) -> Void) {
        completion(.success(Response(data: Data(#"{"result":{"userId":7}}"#.utf8))))
    }
}
struct APIManager {
    static let shared = APIManager()
    func createProvider(for type: MyPageRouter.Type, withAuth: Bool) -> ProfileProvider { ProfileProvider() }
}
final class MeasurementSocketManager {
    static let shared = MeasurementSocketManager()
    var onConnected: (() -> Void)?
    var onMeasurementMessage: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    var topics: [String] = []
    var disconnectCount = 0
    func connect() { onConnected?() }
    func subscribe(to topic: String) { topics.append(topic) }
    func disconnect() { disconnectCount += 1 }
}
@MainActor final class MeasurementAPI {
    static let shared = MeasurementAPI()
    var requests: [MeasurementStatus] = []
    var beforePostResponse: (() async -> Void)?
    var beforePatchResponse: (() async -> Void)?
    var failNextPatch = false
    var failNextPost = false
    func postMeasurementSessions() async throws -> MeasurementSessionResultDTO {
        await beforePostResponse?()
        if failNextPost {
            failNextPost = false
            throw NSError(domain: "test", code: 2)
        }
        return try JSONDecoder().decode(MeasurementSessionResultDTO.self, from: Data(
            #"{"id":142,"deviceId":1,"status":"WAITING_FOR_PHOTO_ENVIRONMENT","measuredAt":"2026-10-14","createdAt":"2026-10-14","webSocketTopic":"/topic/measurements/142"}"#.utf8
        ))
    }
    func patchMeasurementSessionStatus(sessionId: Int, status: MeasurementStatus) async throws -> MeasurementSessionStatusResultDTO {
        assert(sessionId == 142)
        requests.append(status)
        await beforePatchResponse?()
        if failNextPatch {
            failNextPatch = false
            throw NSError(domain: "test", code: 1)
        }
        return try JSONDecoder().decode(MeasurementSessionStatusResultDTO.self, from: Data(
            "{\"id\":142,\"status\":\"\(status.rawValue)\",\"pressureMeasurementAttempt\":1,\"remainingPressureRetries\":2}".utf8
        ))
    }
}

@main struct Check {
    @MainActor static func emit(_ status: MeasurementStatus, sessionID: Int = 142, disconnect: Bool = false, extra: String = "") async throws {
        let body = "{\"eventType\":\"MEASUREMENT_STATUS_CHANGED\",\"measurementSessionId\":\(sessionID),\"status\":\"\(status.rawValue)\",\"shouldDisconnect\":\(disconnect)\(extra)}"
        MeasurementSocketManager.shared.onMeasurementMessage?(body)
        try await _Concurrency.Task.sleep(for: .milliseconds(10))
    }
    @MainActor static func main() async throws {
        let api = MeasurementAPI.shared
        let socket = MeasurementSocketManager.shared
        let vm = FootMeasurementViewModel()
        // A user-topic event arriving before POST returns must survive session creation.
        api.beforePostResponse = { try! await emit(.capturingPhotoEnvironment) }
        await vm.startMeasurementSessionIfNeeded()
        await vm.startMeasurementSessionIfNeeded()
        assert(vm.measurementStatus == .capturingPhotoEnvironment)
        assert(socket.topics == ["/topic/users/7/measurements", "/topic/measurements/142"])
        api.beforePostResponse = nil
        assert(MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture) == .photoMeasurement)

        let readyPairs: [(MeasurementStatus, MeasurementStatus, () async -> Void)] = [
            (.waitingForPhotoEnvironment, .readyForPhotoEnvironment, { await vm.confirmPhotoEnvironmentReady() }),
            (.waitingForRecapture, .readyForRecapture, { await vm.confirmRecaptureReady() }),
            (.waitingForPressure, .readyForPressure, { await vm.confirmPressureReady() }),
            (.waitingForPressureRetry, .readyForPressureRetry, { await vm.confirmPressureRetryReady() })
        ]
        for (waiting, ready, action) in readyPairs {
            try await emit(waiting)
            let waitingGuide = MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture)
            assert(waitingGuide.buttonTitle != nil && waitingGuide.systemImage != nil)
            assert(waitingGuide.spokenDescription == waitingGuide.description, "Preparation steps read their visible description")
            await action()
            assert(vm.measurementStatus == ready)
            let activeGuide = MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture)
            assert(activeGuide.buttonTitle == nil && activeGuide.systemImage == nil, "Ready responses show an animation without a button")
            assert(activeGuide.spokenDescription == nil, "Active measurement must not trigger speech")
            assert(api.requests.last == ready)
            let requestCount = api.requests.count
            await action()
            assert(api.requests.count == requestCount, "Repeated ready taps must not send another request")
            let router = MeasurementRouter.patchSessionStatus(sessionId: 142, status: ready)
            assert(router.path == "/api/measurement-sessions/142/status")
            assert(router.method == .patch)
            guard case let .requestParameters(parameters, encoding) = router.task else { fatalError() }
            assert(encoding == .queryString)
            assert(parameters.count == 1 && parameters["status"] as? String == ready.rawValue)
            assert(ready.rawValue == ready.rawValue.uppercased())
        }
        // Socket progress beats a delayed PATCH response.
        try await emit(.waitingForPressureRetry)
        api.beforePatchResponse = { try! await emit(.measuringPressure) }
        await vm.confirmPressureRetryReady()
        assert(vm.measurementStatus == .measuringPressure)
        api.beforePatchResponse = nil
        // A failed ready request stays retryable.
        try await emit(.waitingForPressureRetry)
        api.failNextPatch = true
        await vm.confirmPressureRetryReady()
        assert(vm.measurementStatus == .waitingForPressureRetry && !vm.isStatusUpdateInFlight)
        await vm.confirmPressureRetryReady()
        assert(vm.measurementStatus == .readyForPressureRetry)

        try await emit(.waitingForPressureRetry, extra: ",\"detail\":\"발 위치를 조정해 주세요\",\"pressureMeasurementAttempt\":2,\"remainingPressureRetries\":1")
        assert(MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture) == .pressureRetryPreparation)
        try await emit(.waitingForRecapture, extra: ",\"statusMessage\":\"사진을 다시 촬영해 주세요\",\"photoCaptureAttempt\":1,\"remainingPhotoRecaptures\":2")
        assert(vm.photoCaptureAttempt == 1)
        assert(MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture) == .recapturePreparation)
        // Recapture can reuse CAPTURING_PHOTO_ENVIRONMENT without an updated attempt counter.
        try await emit(.readyForRecapture)
        try await emit(.capturingPhotoEnvironment)
        assert(vm.isPhotoRecapture && vm.photoCaptureAttempt == 1)
        assert(MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture) == .recapturing)
        try await emit(.analyzing, sessionID: 141)
        assert(vm.measurementStatus == .capturingPhotoEnvironment, "Ignore old-session events")
        try await emit(.analyzing)
        var finishes = 0
        vm.onMoveToFinish = { finishes += 1 }
        try await emit(.completed, disconnect: true)
        try await emit(.completed, disconnect: true)
        assert(finishes == 1 && socket.disconnectCount == 1)
        socket.onError?(NSError(domain: "late-disconnect", code: 1))
        try await _Concurrency.Task.sleep(for: .milliseconds(10))
        assert(vm.measurementStatus == .completed, "A disconnect after completion must not show failure")
        vm.resetMeasurementState()
        await vm.startMeasurementSessionIfNeeded()
        try await emit(.failed, disconnect: true, extra: ",\"failureReason\":\"NEW_SERVER_FAILURE\",\"failureMessage\":\"측정 실패\"")
        assert(vm.measurementStatus == .failed && socket.disconnectCount == 2)
        let failureGuide = MeasurementGuide(status: vm.measurementStatus, isPhotoRecapture: vm.isPhotoRecapture)
        assert(failureGuide == .failed && failureGuide.title == "측정 실패")
        assert(failureGuide.description == "측정 중 문제가 발생했습니다.\n처음부터 다시 시도해 주세요.")
        vm.resetMeasurementState()
        assert(vm.measurementStatus == nil && vm.measurementSessionId == nil && vm.photoCaptureAttempt == nil && !vm.isPhotoRecapture)
        api.failNextPost = true
        await vm.startMeasurementSessionIfNeeded()
        assert(vm.measurementStatus == .failed && vm.errorMessage != nil, "Session creation errors show the retry screen")
        vm.resetMeasurementState()
        await vm.startMeasurementSessionIfNeeded()
        socket.onError?(NSError(domain: "connection-lost", code: 1))
        try await _Concurrency.Task.sleep(for: .milliseconds(10))
        assert(vm.measurementStatus == .failed && !vm.isLoading, "Connection loss during measurement shows the retry screen")
        assert(MeasurementGuide.allCases.filter { $0.buttonTitle != nil }.count == 6)
        assert(MeasurementGuide.allCases.filter { $0.spokenDescription != nil } == [
            .preparation, .photoPreparation, .recapturePreparation, .pressurePreparation, .pressureRetryPreparation, .analyzing
        ], "Preparation steps and the measurement-complete guidance have automatic speech")
        for status in [MeasurementStatus.waitingForPhotoEnvironment, .readyForPhotoEnvironment, .capturingPhotoEnvironment, .waitingForRecapture, .readyForRecapture, .waitingForPressure, .readyForPressure, .measuringPressure, .waitingForPressureRetry, .readyForPressureRetry, .analyzing, .completed, .failed] {
            let decoded = try JSONDecoder().decode(MeasurementStatus.self, from: JSONEncoder().encode(status))
            assert(decoded == status)
        }
        print("PASS: measurement guides, recapture without counters, button transitions, failures/retry, PATCH actions, and socket flow")
    }
}
'''
with tempfile.TemporaryDirectory(prefix="feetfit-measurement-check-") as directory:
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
