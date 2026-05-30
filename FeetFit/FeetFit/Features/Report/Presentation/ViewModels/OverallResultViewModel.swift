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

    func fetchDailyFootAnalysis(date: Date = Date()) async {
        isLoading = true
        errorMessage = nil

        do {
            let dateString = Self.dateFormatter.string(from: date)

            result = try await ReportAPI.shared.fetchDailyFootAnalysis(
                date: dateString
            )
        } catch {
            if error.localizedDescription == "리포트를 찾을 수 없습니다." {
                errorMessage = "해당 날짜에 측정된 발 데이터가 없어요.\n측정 후 결과를 확인해 주세요."
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
