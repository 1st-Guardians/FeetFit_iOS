//
//  OverallResultViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import Combine

@MainActor
final class OverallResultViewModel: ObservableObject {
    @Published var result: DailyFootAnalysisResultDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    let isMock: Bool
    private let emptyDataMessage = "해당 날짜에 측정된 데이터가 없어요.\n측정 후 결과를 확인해 주세요."

    init() {
        self.isMock = false
    }

    #if DEBUG
    init(mockResult: DailyFootAnalysisResultDTO) {
        self.isMock = true
        self.result = mockResult
    }
    #endif

    func fetchDailyFootAnalysis(date: Date = Date()) async {
        isLoading = true
        errorMessage = nil

        do {
            let dateString = Self.dateFormatter.string(from: date)

            let fetchedResult = try await ReportAPI.shared.fetchDailyFootAnalysis(
                date: dateString
            )

            if fetchedResult.hasRequiredOverallDisplayData {
                result = fetchedResult
            } else {
                result = nil
                errorMessage = emptyDataMessage
            }
        } catch {
            if case APIError.notFound = error {
                errorMessage = emptyDataMessage
            } else {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
