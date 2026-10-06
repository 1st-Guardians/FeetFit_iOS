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
            "{{LEFT_FOOT_LENGTH}}": millimeters(data.leftFootLengthMm),
            "{{RIGHT_FOOT_LENGTH}}": millimeters(data.rightFootLengthMm),
            "{{LEFT_FOOT_WIDTH}}": millimeters(data.leftFootWidthMm),
            "{{RIGHT_FOOT_WIDTH}}": millimeters(data.rightFootWidthMm),
            "{{HUMIDITY}}": "\(Int(data.humidityPercent.rounded()))%",
            "{{CARE_TIPS}}": careTips
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
}

private enum ReportHTMLBuilderError: LocalizedError {
    case missingResource(String)

    var errorDescription: String? {
        switch self {
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
