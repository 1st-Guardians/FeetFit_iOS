//
//  SummaryViewModel.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published var report: ReportSummaryResultDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var totalScoreText: String {
        guard let totalScore = report?.totalScore else {
            return "-"
        }

        return "\(Int(totalScore.rounded()))점"
    }

    var radarItems: [RadarChartItem] {
        guard let metricScores = report?.metricScores else {
            return []
        }

        return metricScores
            .filter { $0.score != nil }
            .map { $0.radarItem }
    }

    var yearScores: [YearScore] {
        guard let monthlyScores = report?.monthlyScores else {
            return []
        }

        return monthlyScores
            .filter { $0.month != nil && $0.avgScore != nil }
            .map { $0.yearScore }
    }

    var metricScores: [MetricScoreDTO] {
        report?.metricScores?.filter { !($0.advice ?? []).isEmpty } ?? []
    }

    func fetchSummary() async {
        isLoading = true
        errorMessage = nil

        do {
            report = try await ReportAPI.shared.fetchReportSummary()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
