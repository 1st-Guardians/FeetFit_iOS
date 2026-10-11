//
//  ReportDataLoader.swift
//  FeetFit
//

import Foundation

@MainActor
enum ReportDataLoader {
    private static let profileProvider = NetworkProvider<MyPageRouter>()
    private static let shoeProvider = NetworkProvider<ShoeRoute>()

    static func loadLatest(referenceDate: Date = Date()) async throws -> ReportData {
        let measurementDate = try await latestMeasurementDate(referenceDate: referenceDate)
        return try await load(date: measurementDate)
    }

    static func load(date measurementDate: Date) async throws -> ReportData {
        let apiDate = apiDateFormatter.string(from: measurementDate)

        let profile = try await profileProvider.requestBase(
            .getProfile,
            dataType: MyPageProfileResult.self
        )
        let analysis = try await ReportAPI.shared.fetchDailyFootAnalysis(date: apiDate)
        let hallux = try await ReportAPI.shared.fetchHalluxValgus(date: apiDate)
        let skin = try await ReportAPI.shared.fetchAthletesFoot(date: apiDate)
        let recommendationResult = try await shoeProvider.requestBase(
            .getTopRecommendations,
            dataType: ShoeRecommendationResultDTO.self
        )

        guard recommendationResult.shoes.count >= 3 else {
            throw ReportDataLoaderError.incompleteRecommendation
        }

        let topRecommendations = Array(recommendationResult.shoes.prefix(3))

        async let leftPressureImageTask = imageDataURL(from: analysis.leftPressureImageUrl)
        async let rightPressureImageTask = imageDataURL(from: analysis.rightPressureImageUrl)
        async let leftFootprintImageTask = imageDataURL(from: analysis.leftPlantarFootprintImageUrl)
        async let rightFootprintImageTask = imageDataURL(from: analysis.rightPlantarFootprintImageUrl)
        async let leftHalluxImageTask = imageDataURL(from: hallux.leftImageUrl)
        async let rightHalluxImageTask = imageDataURL(from: hallux.rightImageUrl)
        async let skinImageTask = imageDataURL(from: skin.suspiciousAreaMapImageUrl)
        async let firstShoeTask = reportShoe(from: topRecommendations[0])
        async let secondShoeTask = reportShoe(from: topRecommendations[1])
        async let thirdShoeTask = reportShoe(from: topRecommendations[2])

        let (
            leftPressureImage,
            rightPressureImage,
            leftFootprintImage,
            rightFootprintImage,
            leftHalluxImage,
            rightHalluxImage,
            skinImage
        ) = await (
            leftPressureImageTask,
            rightPressureImageTask,
            leftFootprintImageTask,
            rightFootprintImageTask,
            leftHalluxImageTask,
            rightHalluxImageTask,
            skinImageTask
        )

        let (firstShoe, secondShoe, thirdShoe) = try await (
            firstShoeTask,
            secondShoeTask,
            thirdShoeTask
        )

        guard let reportID = analysis.measurementSessionId ?? analysis.id,
              let balanceScore = analysis.balanceScore,
              let balanceDescription = analysis.balanceComment,
              let leftPressure = analysis.leftPressurePercent,
              let rightPressure = analysis.rightPressurePercent,
              let pressureDescription = analysis.plantarFootprintAnalysisText,
              let leftFootLength = analysis.measuredLeftFootSizeMm,
              let rightFootLength = analysis.measuredRightFootSizeMm,
              let leftFootWidth = analysis.leftFootWidthMm,
              let rightFootWidth = analysis.rightFootWidthMm,
              let humidity = analysis.avgHumidityPercent,
              let footTypeDescription = nonEmpty(analysis.typeText) else {
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
            leftPressurePercent: leftPressure,
            rightPressurePercent: rightPressure,
            pressureDescription: pressureDescription,
            leftPressureImageDataURL: leftPressureImage,
            rightPressureImageDataURL: rightPressureImage,
            leftFootprintImageDataURL: leftFootprintImage,
            rightFootprintImageDataURL: rightFootprintImage,
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
            careTips: analysis.careTips ?? [],
            footTypeDescription: footTypeDescription,
            recommendedShoes: [firstShoe, secondShoe, thirdShoe]
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

    private static func reportShoe(
        from recommendation: ShoeRecommendationDTO
    ) async throws -> ReportShoeData {
        guard let fitScore = recommendation.fitScore else {
            throw ReportDataLoaderError.incompleteRecommendation
        }

        async let imageTask = imageDataURL(from: recommendation.imageUrl)
        let detail = try await shoeProvider.requestBase(
            .getShoeDetail(shoeId: recommendation.id),
            dataType: ShoeDetailResultDTO.self
        )
        let image = await imageTask

        let description = nonEmpty(detail.pointSummary)
            ?? detail.reasons.lazy.compactMap { nonEmpty($0.reviewSummary) }.first
            ?? "발 측정 결과를 기반으로 추천된 신발입니다."

        return ReportShoeData(
            brand: recommendation.brandName,
            name: recommendation.shoeName,
            price: recommendation.price,
            fitScore: fitScore,
            imageDataURL: image,
            description: description
        )
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private nonisolated static func imageDataURL(from value: String?) async -> String? {
        guard let value,
              let url = URL(string: value),
              ["http", "https"].contains(url.scheme?.lowercased()) else {
            return nil
        }

        guard let (data, response) = try? await URLSession.shared.data(from: url),
              !data.isEmpty,
              let mimeType = response.mimeType?.lowercased(),
              ["image/gif", "image/jpeg", "image/jpg", "image/png", "image/webp"].contains(mimeType),
              (response as? HTTPURLResponse).map({ 200..<300 ~= $0.statusCode }) ?? true else {
            return nil
        }

        return "data:\(mimeType);base64,\(data.base64EncodedString())"
    }
}

private enum ReportDataLoaderError: LocalizedError {
    case incompleteRecommendation
    case incompleteMeasurement
    case invalidReferenceDate
    case noMeasurement

    var errorDescription: String? {
        switch self {
        case .incompleteRecommendation:
            return "PDF 생성에 필요한 추천 신발 데이터가 부족합니다."
        case .incompleteMeasurement:
            return "최근 측정 결과에 PDF 생성에 필요한 데이터가 없습니다."
        case .invalidReferenceDate:
            return "최근 측정일을 계산할 수 없습니다."
        case .noMeasurement:
            return "완료된 측정 기록이 없습니다."
        }
    }
}
