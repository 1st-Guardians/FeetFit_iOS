//
//  ReportHTMLBuilder.swift
//  FeetFit
//

import Foundation

struct ReportHTMLBuilder {
    static func makeHTML(
        data: ReportData,
        bundle: Bundle = .main
    ) throws -> String {
        let html = try resource(named: "report", extension: "html", in: bundle)
        let css = try resource(named: "report", extension: "css", in: bundle)
        let balanceScore = min(max(data.balanceScore, 0), 100)
        let leftPressure = min(max(Int(data.leftPressurePercent.rounded()), 0), 100)
        let rightPressure = min(max(Int(data.rightPressurePercent.rounded()), 0), 100)
        let halluxScore = min(max(data.halluxScore, 0), 100)
        let skinScore = min(max(data.skinScore, 0), 100)
        let fungalScore = min(max(Int(data.fungalSuspicionScore.rounded()), 0), 100)
        let reactionScore = min(max(Int(data.skinReactionScore.rounded()), 0), 100)
        guard data.recommendedShoes.count >= 3 else {
            throw ReportHTMLBuilderError.invalidRecommendationCount
        }
        let firstShoe = data.recommendedShoes[0]
        let secondShoe = data.recommendedShoes[1]
        let thirdShoe = data.recommendedShoes[2]
        let careTips = data.careTips
            .map { "<li>\($0.htmlEscaped)</li>" }
            .joined(separator: "\n")

        let replacements = [
            "{{REPORT_CSS}}": css,
            "{{NAME}}": data.name.htmlEscaped,
            "{{AGE}}": String(data.age),
            "{{HEIGHT}}": String(data.height),
            "{{MEASUREMENT_DATE}}": data.measurementDate.htmlEscaped,
            "{{REPORT_NUMBER}}": data.reportNumber.htmlEscaped,
            "{{BALANCE_SCORE}}": String(balanceScore),
            "{{BALANCE_DESCRIPTION}}": data.balanceDescription.htmlEscaped,
            "{{LEFT_PRESSURE}}": String(leftPressure),
            "{{RIGHT_PRESSURE}}": String(rightPressure),
            "{{PRESSURE_DOMINANT}}": pressureDominant(
                left: leftPressure,
                right: rightPressure
            ),
            "{{PRESSURE_DESCRIPTION}}": data.pressureDescription.htmlEscaped,
            "{{LEFT_PRESSURE_IMAGE}}": imageSource(data.leftPressureImageDataURL),
            "{{RIGHT_PRESSURE_IMAGE}}": imageSource(data.rightPressureImageDataURL),
            "{{LEFT_FOOTPRINT_IMAGE}}": imageSource(data.leftFootprintImageDataURL),
            "{{RIGHT_FOOTPRINT_IMAGE}}": imageSource(data.rightFootprintImageDataURL),
            "{{HALLUX_SCORE}}": String(halluxScore),
            "{{HALLUX_DESCRIPTION}}": data.halluxDescription.htmlEscaped,
            "{{HALLUX_SEVERITY}}": halluxSeverity(
                leftAngle: data.leftHalluxAngleDegree,
                rightAngle: data.rightHalluxAngleDegree
            ),
            "{{LEFT_HALLUX_ANGLE}}": String(Int(data.leftHalluxAngleDegree.rounded())),
            "{{RIGHT_HALLUX_ANGLE}}": String(Int(data.rightHalluxAngleDegree.rounded())),
            "{{LEFT_HALLUX_DESCRIPTION}}": data.leftHalluxDescription.htmlEscaped,
            "{{RIGHT_HALLUX_DESCRIPTION}}": data.rightHalluxDescription.htmlEscaped,
            "{{LEFT_HALLUX_IMAGE}}": imageSource(data.leftHalluxImageDataURL),
            "{{RIGHT_HALLUX_IMAGE}}": imageSource(data.rightHalluxImageDataURL),
            "{{SKIN_SCORE}}": String(skinScore),
            "{{SKIN_DESCRIPTION}}": data.skinDescription.htmlEscaped,
            "{{FUNGAL_SCORE}}": String(fungalScore),
            "{{REACTION_SCORE}}": String(reactionScore),
            "{{FUNGAL_DESCRIPTION}}": data.fungalSuspicionDescription.htmlEscaped,
            "{{REACTION_DESCRIPTION}}": data.skinReactionDescription.htmlEscaped,
            "{{SKIN_IMAGE}}": imageSource(data.skinImageDataURL),
            "{{SKIN_FORMULA}}": skinFormula(
                fungalScore: data.fungalSuspicionScore,
                reactionScore: data.skinReactionScore
            ).htmlEscaped,
            "{{LEFT_FOOT_LENGTH}}": millimeters(data.leftFootLengthMm),
            "{{RIGHT_FOOT_LENGTH}}": millimeters(data.rightFootLengthMm),
            "{{LEFT_FOOT_WIDTH}}": millimeters(data.leftFootWidthMm),
            "{{RIGHT_FOOT_WIDTH}}": millimeters(data.rightFootWidthMm),
            "{{HUMIDITY}}": "\(Int(data.humidityPercent.rounded()))%",
            "{{CARE_TIPS}}": careTips,
            "{{FOOT_TYPE_DESCRIPTION}}": data.footTypeDescription.htmlEscaped,
            "{{SHOE_1_BRAND}}": firstShoe.brand.htmlEscaped,
            "{{SHOE_1_NAME}}": firstShoe.name.htmlEscaped,
            "{{SHOE_1_PRICE}}": price(firstShoe.price),
            "{{SHOE_1_SCORE}}": fitScore(firstShoe.fitScore),
            "{{SHOE_1_IMAGE}}": imageSource(firstShoe.imageDataURL),
            "{{SHOE_1_DESCRIPTION}}": firstShoe.description.htmlEscaped,
            "{{SHOE_2_BRAND}}": secondShoe.brand.htmlEscaped,
            "{{SHOE_2_NAME}}": secondShoe.name.htmlEscaped,
            "{{SHOE_2_PRICE}}": price(secondShoe.price),
            "{{SHOE_2_SCORE}}": fitScore(secondShoe.fitScore),
            "{{SHOE_2_IMAGE}}": imageSource(secondShoe.imageDataURL),
            "{{SHOE_2_DESCRIPTION}}": secondShoe.description.htmlEscaped,
            "{{SHOE_3_BRAND}}": thirdShoe.brand.htmlEscaped,
            "{{SHOE_3_NAME}}": thirdShoe.name.htmlEscaped,
            "{{SHOE_3_PRICE}}": price(thirdShoe.price),
            "{{SHOE_3_SCORE}}": fitScore(thirdShoe.fitScore),
            "{{SHOE_3_IMAGE}}": imageSource(thirdShoe.imageDataURL),
            "{{SHOE_3_DESCRIPTION}}": thirdShoe.description.htmlEscaped
        ]

        return replacements.reduce(html) { result, replacement in
            result.replacingOccurrences(of: replacement.key, with: replacement.value)
        }
    }

    private static func resource(
        named name: String,
        extension fileExtension: String,
        in bundle: Bundle
    ) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            throw ReportHTMLBuilderError.missingResource("\(name).\(fileExtension)")
        }

        return try String(contentsOf: url, encoding: .utf8)
    }

    private static func millimeters(_ value: Double) -> String {
        String(format: "%.1fmm", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private static func fitScore(_ value: Double) -> String {
        String(min(max(Int(value.rounded()), 0), 100))
    }

    private static func price(_ value: Int) -> String {
        value.formatted(
            .number
                .grouping(.automatic)
                .locale(Locale(identifier: "ko_KR"))
        ) + "원"
    }

    private static func halluxSeverity(leftAngle: Double, rightAngle: Double) -> String {
        switch max(leftAngle, rightAngle) {
        case ...15:
            return "normal"
        case ...20:
            return "suspected"
        case ...40:
            return "progressing"
        default:
            return "severe"
        }
    }

    private static func pressureDominant(left: Int, right: Int) -> String {
        if left == right { return "balanced" }
        return left > right ? "left" : "right"
    }

    private static func skinFormula(fungalScore: Double, reactionScore: Double) -> String {
        let total = fungalScore * 0.7 + reactionScore * 0.3

        return """
        무좀 의심 영역 70% + 염증 반응 영역 30%으로 계산됩니다.
        \(formattedScore(fungalScore)) × 0.7 + \(formattedScore(reactionScore)) × 0.3 = \(formattedScore(total))점으로 계산되었습니다.
        """
    }

    private static func formattedScore(_ value: Double) -> String {
        value.rounded() == value
            ? String(Int(value))
            : String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), value)
    }

    private static func imageSource(_ dataURL: String?) -> String {
        (dataURL ?? transparentImageDataURL).htmlEscaped
    }

    private static let transparentImageDataURL =
        "data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs="
}

private enum ReportHTMLBuilderError: LocalizedError {
    case invalidRecommendationCount
    case missingResource(String)

    var errorDescription: String? {
        switch self {
        case .invalidRecommendationCount:
            return "PDF 생성에 필요한 추천 신발 데이터가 부족합니다."
        case .missingResource(let filename):
            return "PDF 템플릿 파일을 찾을 수 없습니다: \(filename)"
        }
    }
}

private extension String {
    var htmlEscaped: String {
        replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
