//
//  ReportSummaryResponseDTO.swift
//  FeetFit
//
//  Created by 이채은 on 5/31/26.
//

import Foundation

struct ReportSummaryResponseDTO: Decodable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ReportSummaryResultDTO
}

struct ReportSummaryResultDTO: Decodable {
    let totalScore: Int
    let metricScores: [MetricScoreDTO]
    let monthlyScores: [MonthlyScoreDTO]
}

struct MetricScoreDTO: Decodable, Identifiable {
    var id: String { metricType }

    let metricType: String
    let score: Double
    let status: String
    let advice: [String]
}

struct MonthlyScoreDTO: Decodable, Identifiable {
    var id: Int { month }

    let month: Int
    let avgScore: Double
}

extension MetricScoreDTO {
    var displayTitle: String {
        switch metricType {
        case "PRESSURE_BALANCE":
            return "압력 균형"
        case "HALLUX_VALGUS":
            return "무지외반"
        case "ATHLETES_FOOT":
            return "무좀 위험도"
        case "FOOT_ODOR":
            return "피부 자극도"
        case "FOOT_ENVIRONMENT":
            return "환경 상태"
        default:
            return metricType
        }
    }

    var mainBoxStatus: MainBoxStatus {
        switch status {
        case "VERY_GOOD":
            return .good
        case "ATTENTION_NEEDED":
            return .warn
        case "NEED_IMPROVEMENT":
            return .bad
        default:
            return .warn
        }
    }

    var radarItem: RadarChartItem {
        RadarChartItem(
            title: displayTitle,
            value: score / 100.0
        )
    }
}

extension MonthlyScoreDTO {
    var yearScore: YearScore {
        YearScore(
            month: "\(month)월",
            score: Int(avgScore.rounded())
        )
    }
}
