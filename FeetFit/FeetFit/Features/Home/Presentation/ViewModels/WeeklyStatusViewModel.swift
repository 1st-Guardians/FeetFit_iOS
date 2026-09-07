//
//  WeeklyStatusViewModel.swift
//  FeetFit
//
//  Created by 김미주 on 6/28/26.
//

import Foundation
import Combine
import Moya

@MainActor
final class WeeklyStatusViewModel: ObservableObject {
    @Published var weeklyStatus: WeeklyStatus?
    @Published var isDeviceConnected: Bool?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let deviceProvider = APIManager.shared.createProvider(
        for: DeviceRouter.self,
        withAuth: true
    )

    var todayDate: Date? {
        guard let today = weeklyStatus?.today else { return nil }
        return Self.dateFormatter.date(from: today)
    }

    var homeStatus: HomeStatus {
        if isDeviceConnected == false {
            return .hardwareUnconnected
        }

        guard let status = weeklyStatus else { return .noRecord }
        let todayHasMeasurement = status.dailyStatuses
            .first { $0.date == status.today }?
            .hasMeasurement == true
        if todayHasMeasurement { return .measuredToday }
        if status.hasWeeklyMeasurement { return .notMeasuredToday }
        return .noRecord
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "Asia/Seoul")
        return f
    }()

    func fetchWeeklyStatus() async {
        isLoading = true
        errorMessage = nil

        do {
            weeklyStatus = try await MeasurementAPI.shared.fetchWeeklyStatus()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchDeviceStatus() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            deviceProvider.request(.getDevice) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        print("홈 하드웨어 연결 상태 statusCode:", response.statusCode)

                        let decodedData = try JSONDecoder().decode(
                            BaseResponse<DeviceResponse>.self,
                            from: response.data
                        )

                        guard decodedData.isSuccess else {
                            continuation.resume()
                            return
                        }

                        DispatchQueue.main.async {
                            self?.isDeviceConnected = decodedData.result?.deviceConnected
                            continuation.resume()
                        }
                    } catch {
                        print("홈 하드웨어 연결 상태 디코더 오류:", error)
                        print("서버 응답:", String(data: response.data, encoding: .utf8) ?? "응답 없음")
                        continuation.resume()
                    }

                case .failure(let error):
                    print("홈 하드웨어 연결 상태 API 오류:", error)
                    continuation.resume()
                }
            }
        }
    }
}
