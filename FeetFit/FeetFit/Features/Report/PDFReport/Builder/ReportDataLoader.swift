//
//  ReportDataLoader.swift
//  FeetFit
//

import Foundation

@MainActor
enum ReportDataLoader {
    private static let profileProvider = NetworkProvider<MyPageRouter>()

    static func loadLatest(referenceDate: Date = Date()) async throws -> ReportData {
        let measurementDate = try await latestMeasurementDate(referenceDate: referenceDate)
        let apiDate = apiDateFormatter.string(from: measurementDate)

        let profile = try await profileProvider.requestBase(
            .getProfile,
            dataType: MyPageProfileResult.self
        )
        let analysis = try await ReportAPI.shared.fetchDailyFootAnalysis(date: apiDate)

        guard let reportID = analysis.measurementSessionId ?? analysis.id,
              let balanceScore = analysis.balanceScore,
              let balanceDescription = analysis.balanceComment,
              let leftFootLength = analysis.measuredLeftFootSizeMm,
              let rightFootLength = analysis.measuredRightFootSizeMm,
              let leftFootWidth = analysis.leftFootWidthMm,
              let rightFootWidth = analysis.rightFootWidthMm,
              let humidity = analysis.avgHumidityPercent else {
            throw ReportDataLoaderError.incompleteMeasurement
        }

        return ReportData(
            name: profile.nickname,
            age: profile.age,
            height: Int(profile.heightCm.rounded()),
            measurementDate: displayDateFormatter.string(from: measurementDate),
            reportNumber: "\(reportDateFormatter.string(from: measurementDate))-\(String(format: "%05d", reportID))",
            balanceScore: Int(balanceScore.rounded()),
            balanceDescription: balanceDescription,
            leftFootLengthMm: leftFootLength,
            rightFootLengthMm: rightFootLength,
            leftFootWidthMm: leftFootWidth,
            rightFootWidthMm: rightFootWidth,
            humidityPercent: humidity,
            careTips: analysis.careTips ?? []
        )
    }

    static func latestMeasurementDate(referenceDate: Date = Date()) async throws -> Date {
        let calendar = Calendar.current
        guard var monthDate = calendar.date(
            from: calendar.dateComponents([.year, .month], from: referenceDate)
        ) else {
            throw ReportDataLoaderError.invalidReferenceDate
        }

        // ponytail: Cap monthly lookups until the API provides a latest-record endpoint.
        for _ in 0..<60 {
            let year = calendar.component(.year, from: monthDate)
            let month = calendar.component(.month, from: monthDate)
            let dates = try await ReportAPI.shared.fetchMeasuredDates(
                year: year,
                month: month
            )

            if let latestDate = dates
                .filter({ $0 <= referenceDate })
                .max() {
                return latestDate
            }

            guard let previousMonth = calendar.date(
                byAdding: .month,
                value: -1,
                to: monthDate
            ) else {
                break
            }
            monthDate = previousMonth
        }

        throw ReportDataLoaderError.noMeasurement
    }

    private static let apiDateFormatter: DateFormatter = makeDateFormatter("yyyy-MM-dd")
    private static let displayDateFormatter: DateFormatter = makeDateFormatter("yyyy.MM.dd")
    private static let reportDateFormatter: DateFormatter = makeDateFormatter("yyyyMMdd")

    private static func makeDateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }
}

private enum ReportDataLoaderError: LocalizedError {
    case incompleteMeasurement
    case invalidReferenceDate
    case noMeasurement

    var errorDescription: String? {
        switch self {
        case .incompleteMeasurement:
            return "최근 측정 결과에 PDF 생성에 필요한 데이터가 없습니다."
        case .invalidReferenceDate:
            return "최근 측정일을 계산할 수 없습니다."
        case .noMeasurement:
            return "완료된 측정 기록이 없습니다."
        }
    }
}
