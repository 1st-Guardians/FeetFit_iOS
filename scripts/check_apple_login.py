#!/usr/bin/env python3
"""Check production login routes and state with local Apple/Kakao and network stubs."""
from pathlib import Path
import os
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1] / "FeetFit/FeetFit"
files = [
    "Core/Network/BaseResponse.swift",
    "Core/Network/APIErrorResponse.swift",
    "Features/Onboarding/Data/DTO/LoginDTO.swift",
    "Features/Onboarding/Data/API/AuthRouter.swift",
    "Features/Onboarding/Presentation/ViewModels/LoginViewModel.swift",
]
excluded_imports = {"import Moya", "import Alamofire", "import AuthenticationServices",
                    "import KakaoSDKAuth", "import KakaoSDKCommon", "import KakaoSDKUser"}
production = "\n".join(
    "\n".join(line for line in (root / name).read_text().splitlines() if line not in excluded_imports)
    for name in files
)
harness = r'''
enum Moya { enum Method { case post } }
enum URLEncoding { case httpBody }
enum Task {
    case requestParameters(parameters: [String: Any], encoding: URLEncoding)
    case requestJSONEncodable(Encodable)
}
protocol APITargetType {}
struct ASAuthorization { let credential: Any }
struct ASAuthorizationAppleIDCredential { let authorizationCode: Data? }
struct ASAuthorizationError: Error {
    enum Code { case canceled, failed }
    let code: Code
}
struct OAuthToken { let accessToken: String }
final class UserApi {
    static let shared = UserApi()
    static var talkAvailable = false
    static func isKakaoTalkLoginAvailable() -> Bool { talkAvailable }
    func loginWithKakaoTalk(completion: (OAuthToken?, Error?) -> Void) {
        completion(OAuthToken(accessToken: "kakao-talk"), nil)
    }
    func loginWithKakaoAccount(completion: (OAuthToken?, Error?) -> Void) {
        completion(OAuthToken(accessToken: "kakao-account"), nil)
    }
}
struct Response { let data: Data; var statusCode = 200 }
struct RequestError: Error { let response: Response? }
final class LoginProvider {
    var pending: [(route: AuthRouter, completion: (Result<Response, RequestError>) -> Void)] = []
    func request(_ route: AuthRouter, completion: @escaping (Result<Response, RequestError>) -> Void) {
        pending.append((route, completion))
    }
    func complete(_ json: String, failed: Bool = false, statusCode: Int = 200) {
        let response = Response(data: Data(json.utf8), statusCode: statusCode)
        pending.last!.completion(failed ? .failure(RequestError(response: response)) : .success(response))
    }
}
struct APIManager {
    static let shared = APIManager()
    let provider = LoginProvider()
    func createProvider(for type: AuthRouter.Type, withAuth: Bool) -> LoginProvider {
        assert(!withAuth, "Login must not attach existing authentication or retry a one-time code via the auth interceptor")
        return provider
    }
}
@MainActor final class TokenManager {
    static let shared = TokenManager()
    var saves: [(access: String, refresh: String)] = []
    func save(accessToken: String, refreshToken: String) {
        saves.append((accessToken, refreshToken))
    }
}
@MainActor final class ToastManager {
    static let shared = ToastManager()
    var messages: [String] = []
    func show(_ message: String) { messages.append(message) }
}
@main struct Check {
    static func apple(_ data: Data?) -> Result<ASAuthorization, Error> {
        .success(ASAuthorization(credential: ASAuthorizationAppleIDCredential(authorizationCode: data)))
    }
    static func success(profile: Bool, access: String = "feetfit-access") -> String {
        """
        {"isSuccess":true,"code":"COMMON200","message":"성공입니다.","result":{"accessToken":"\(access)","refreshToken":"feetfit-refresh","grantType":"Bearer","expiresIn":1792386045000,"requiresProfileSetup":\(profile)}}
        """
    }
    static func drain() async { try! await _Concurrency.Task.sleep(for: .milliseconds(10)) }

    @MainActor static func main() async throws {
        let provider = APIManager.shared.provider
        let tokens = TokenManager.shared
        let toast = ToastManager.shared
        let code = "once+only/code=&? 한글"
        let route = AuthRouter.postApple(code: code)
        assert(route.path == "/api/auth/apple" && route.method == .post)
        assert(route.headers == ["Content-Type": "application/x-www-form-urlencoded"])
        guard case let .requestParameters(parameters, encoding) = route.task else { fatalError("Apple must send a form body, not JSON") }
        assert(encoding == .httpBody && parameters.count == 1 && parameters["code"] as? String == code,
               "Pass the original code to Alamofire's form-body encoder, including special characters")

        let vm = LoginViewModel()
        vm.handleAppleAuthorization(.failure(ASAuthorizationError(code: .canceled)))
        assert(provider.pending.isEmpty && toast.messages.isEmpty && !vm.isLoggingIn)
        for data in [nil, Data(), Data("  \n".utf8), Data([0xff])] as [Data?] {
            vm.handleAppleAuthorization(apple(data))
            assert(provider.pending.isEmpty && !vm.isLogin && !vm.isLoggingIn)
        }
        vm.handleAppleAuthorization(.success(ASAuthorization(credential: "not-an-apple-credential")))
        assert(provider.pending.isEmpty)
        vm.handleAppleAuthorization(.failure(ASAuthorizationError(code: .failed)))
        assert(toast.messages.last == "애플 로그인에 실패했습니다. 다시 시도해 주세요.")

        vm.handleAppleAuthorization(apple(Data(code.utf8)))
        assert(provider.pending.count == 1 && vm.isLoggingIn)
        vm.handleAppleAuthorization(apple(Data(code.utf8)))
        vm.kakaoLogin()
        assert(provider.pending.count == 1, "Disable duplicate logins while the backend request is pending")
        provider.complete(#"{"isSuccess":false,"code":"AUTH4004","message":"애플 로그인에 실패했습니다.","result":null}"#, failed: true)
        await drain()
        assert(!vm.isLogin && !vm.isLoggingIn && tokens.saves.isEmpty)
        assert(provider.pending.count == 1 && toast.messages.last == "애플 로그인에 실패했습니다.",
               "A rejected one-time code must not be automatically resent")

        vm.handleAppleAuthorization(apple(Data("fresh-code".utf8)))
        guard case .postApple(let freshCode) = provider.pending.last!.route else { fatalError() }
        assert(freshCode == "fresh-code" && provider.pending.count == 2)
        provider.complete(success(profile: true))
        await drain()
        assert(vm.isLogin && vm.requiresProfileSetup && !vm.isLoggingIn)
        assert(tokens.saves.last!.access == "feetfit-access" && tokens.saves.last!.refresh == "feetfit-refresh")
        vm.handleAppleAuthorization(apple(Data("ignored-after-success".utf8)))
        assert(provider.pending.count == 2)

        let existingUser = LoginViewModel()
        existingUser.handleAppleAuthorization(apple(Data("existing-user-code".utf8)))
        provider.complete(success(profile: false))
        await drain()
        assert(existingUser.isLogin && !existingUser.requiresProfileSetup)
        let decoded = try JSONDecoder().decode(BaseResponse<LoginResponse>.self, from: Data(success(profile: false).utf8))
        assert(decoded.result?.expiresIn == 1792386045000, "Keep the millisecond expiry as Int64")

        let errorCases = [
            (#"{"isSuccess":false,"code":"COMMON400","message":"잘못된 요청입니다.","result":{"code":"Apple Authorization Code는 필수입니다."}}"#, true, "잘못된 요청입니다."),
            (#"{"isSuccess":false,"code":"AUTH5001","message":"애플 로그인 설정이 올바르지 않습니다.","result":null}"#, true, "애플 로그인 설정이 올바르지 않습니다."),
            (#"{"isSuccess":false,"code":"AUTH5002","message":"애플 비공개 키를 읽을 수 없습니다.","result":null}"#, true, "애플 비공개 키를 읽을 수 없습니다."),
            (#"{"isSuccess":false,"code":"AUTH5003","message":"애플 Client Secret 생성에 실패했습니다.","result":null}"#, true, "애플 Client Secret 생성에 실패했습니다."),
            (#"{"isSuccess":false,"code":"AUTH4004","message":"인증 실패","result":null}"#, false, "인증 실패"),
            (#"{"isSuccess":true,"code":"COMMON200","message":"성공","result":null}"#, false, "로그인 응답이 비어 있습니다."),
            ("invalid JSON", false, "로그인 응답을 처리하지 못했습니다."),
            (success(profile: false, access: ""), false, "로그인 응답을 처리하지 못했습니다.")
        ]
        for (json, failed, message) in errorCases {
            let failing = LoginViewModel()
            let previousSaves = tokens.saves.count
            failing.handleAppleAuthorization(apple(Data(UUID().uuidString.utf8)))
            provider.complete(json, failed: failed)
            await drain()
            assert(!failing.isLogin && !failing.isLoggingIn && tokens.saves.count == previousSaves)
            assert(toast.messages.last == message)
        }
        let offline = LoginViewModel()
        offline.handleAppleAuthorization(apple(Data("offline-code".utf8)))
        provider.pending.last!.completion(.failure(RequestError(response: nil)))
        await drain()
        assert(!offline.isLogin && !offline.isLoggingIn && toast.messages.last == "로그인에 실패했습니다. 다시 시도해 주세요.")

        let gatewayFailure = LoginViewModel()
        gatewayFailure.handleAppleAuthorization(apple(Data("gateway-code".utf8)))
        provider.complete("<html><h1>502 Bad Gateway</h1></html>", failed: true, statusCode: 502)
        await drain()
        assert(!gatewayFailure.isLogin && !gatewayFailure.isLoggingIn)
        assert(toast.messages.last == "로그인 서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.")

        for usesTalk in [false, true] {
            UserApi.talkAvailable = usesTalk
            let kakao = LoginViewModel()
            kakao.kakaoLogin()
            let route = provider.pending.last!.route
            assert(route.path == "/api/auth/kakao" && route.headers?["Content-Type"] == "application/json")
            guard case let .requestJSONEncodable(request) = route.task else { fatalError("Kakao remains JSON") }
            let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as! [String: String]
            assert(json == ["accessToken": usesTalk ? "kakao-talk" : "kakao-account"])
            provider.complete(success(profile: false))
            await drain()
            assert(kakao.isLogin && !kakao.requiresProfileSetup)
        }
        print("PASS: Apple form-body contract, code validation, cancellation, one-time request handling, tokens/profile branches, API errors, and Kakao regression")
    }
}
'''
with tempfile.TemporaryDirectory(prefix="feetfit-apple-login-check-") as directory:
    work = Path(directory)
    source = work / "check.swift"
    source.write_text(production + "\n" + harness)
    env = os.environ | {"DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"}
    subprocess.run(["xcrun", "swiftc", "-parse-as-library", "-module-cache-path", str(work / "cache"), str(source), "-o", str(work / "check")], env=env, check=True)
    subprocess.run([str(work / "check")], check=True)
