//
//  ReportPDFGenerator.swift
//  FeetFit
//

import Foundation
import UIKit
import WebKit

@MainActor
enum ReportPDFGenerator {
    private static let a4PageRect = CGRect(
        x: 0,
        y: 0,
        width: 595.28,
        height: 841.89
    )

    static func generate(data: ReportData) async throws -> URL {
        let html = try ReportHTMLBuilder.makeHTML(data: data)
        let webView = WKWebView(frame: a4PageRect)
        let loadDelegate = ReportWebViewLoadDelegate()

        webView.navigationDelegate = loadDelegate
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        try await loadDelegate.load(
            html: html,
            in: webView,
            baseURL: Bundle.main.resourceURL
        )

        webView.layoutIfNeeded()

        let pdfData = try makePDF(from: webView)
        let userName = data.name.replacingOccurrences(of: "/", with: "_")
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("feetfit_report_\(userName).pdf")

        try pdfData.write(to: fileURL, options: .atomic)
        return fileURL
    }

    // UIPrintPageRenderer honors print CSS and paginates repeated .page sections
    // while keeping every output page at the exact A4 point size.
    private static func makePDF(from webView: WKWebView) throws -> Data {
        let printFormatter = webView.viewPrintFormatter()
        printFormatter.perPageContentInsets = .zero

        let pageRenderer = A4PrintPageRenderer(pageRect: a4PageRect)
        pageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)

        let pageCount = pageRenderer.numberOfPages
        guard pageCount > 0 else {
            throw ReportPDFGeneratorError.emptyDocument
        }

        pageRenderer.prepare(
            forDrawingPages: NSRange(location: 0, length: pageCount)
        )

        return UIGraphicsPDFRenderer(bounds: a4PageRect).pdfData { context in
            for pageIndex in 0..<pageCount {
                context.beginPage()
                pageRenderer.drawPage(at: pageIndex, in: a4PageRect)
            }
        }
    }
}

@MainActor
private final class ReportWebViewLoadDelegate: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Error>?

    func load(
        html: String,
        in webView: WKWebView,
        baseURL: URL?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            webView.loadHTMLString(html, baseURL: baseURL)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        continuation?.resume()
        continuation = nil
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation?,
        withError error: Error
    ) {
        finish(throwing: error)
    }

    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation?,
        withError error: Error
    ) {
        finish(throwing: error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        finish(throwing: ReportPDFGeneratorError.webContentProcessTerminated)
    }

    private func finish(throwing error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

@MainActor
private final class A4PrintPageRenderer: UIPrintPageRenderer {
    private let pageRect: CGRect

    init(pageRect: CGRect) {
        self.pageRect = pageRect
        super.init()
    }

    override var paperRect: CGRect { pageRect }
    override var printableRect: CGRect { pageRect }
}

private enum ReportPDFGeneratorError: LocalizedError {
    case emptyDocument
    case webContentProcessTerminated

    var errorDescription: String? {
        switch self {
        case .emptyDocument:
            return "생성된 PDF에 페이지가 없습니다."
        case .webContentProcessTerminated:
            return "PDF용 HTML 렌더링이 중단되었습니다."
        }
    }
}
