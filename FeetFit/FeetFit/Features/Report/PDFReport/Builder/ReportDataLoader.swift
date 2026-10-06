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
        let hallux = try await ReportAPI.shared.fetchHalluxValgus(date: apiDate)
        let skin = try await ReportAPI.shared.fetchAthletesFoot(date: apiDate)
        let leftHalluxImage = await imageDataURL(from: hallux.leftImageUrl)
        let rightHalluxImage = await imageDataURL(from: hallux.rightImageUrl)
        let skinImage = await imageDataURL(from: skin.suspiciousAreaMapImageUrl)

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
            halluxScore: hallux.riskScoreInt,
            halluxDescription: hallux.scoreAnalysisText,
            leftHalluxAngleDegree: hallux.leftToeAngleDegree,
            rightHalluxAngleDegree: hallux.rightToeAngleDegree,
            leftHalluxDescription: hallux.leftAnalysisText,
            rightHalluxDescription: hallux.rightAnalysisText,
            leftHalluxImageDataURL: leftHalluxImage,
            rightHalluxImageDataURL: rightHalluxImage,
            skinScore: skin.totalScoreInt,
            skinDescription: skin.totalScoreDescription,
            fungalSuspicionScore: skin.fungalSuspicionSafetyScore,
            skinReactionScore: skin.skinReactionSafetyScore,
            fungalSuspicionDescription: skin.fungalSuspicionSafetyDescription,
            skinReactionDescription: skin.skinReactionSafetyDescription,
            skinImageDataURL: skinImage,
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

    private static func imageDataURL(from value: String?) async -> String? {
        guard let value,
              let url = URL(string: value),
              ["http", "https"].contains(url.scheme?.lowercased()) else {
            return nil
        }

        guard let (data, response) = try? await URLSession.shared.data(from: url),
              !data.isEmpty,
              let mimeType = response.mimeType?.lowercased(),
              supportedImageMIMETypes.contains(mimeType),
              (response as? HTTPURLResponse).map({ 200..<300 ~= $0.statusCode }) ?? true else {
            return nil
        }

        return "data:\(mimeType);base64,\(data.base64EncodedString())"
    }

    private static let supportedImageMIMETypes = [
        "image/gif",
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp"
    ]
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
