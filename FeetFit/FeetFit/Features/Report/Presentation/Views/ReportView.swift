//
//  ReportView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI
import UIKit

struct ReportView: View {
    @StateObject private var calendarViewModel = CalendarViewModel()
    @State private var selectedMenu: ReportMenuType = .resultReport
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            switch selectedMenu {
            case .resultReport:
                ResultView(selectedDate: selectedDate)
                    .id(Calendar.current.startOfDay(for: selectedDate))

            case .summary:
                SummaryView()
            }
        }
        .task {
            await calendarViewModel.fetchMeasuredDates(for: selectedDate)
        }
        .modifier(ReportPDFShareModifier(selectedDate: selectedDate))
        .toolbar {
            ToolBarCollection.ReportMenu(selection: $selectedMenu)

            if selectedMenu == .resultReport {
                ToolBarCollection.CalendarBtn(
                    selectedDate: $selectedDate,
                    measuredDates: calendarViewModel.measuredDates,
                    onMonthChange: { monthDate in
                        Task {
                            await calendarViewModel.fetchMeasuredDates(for: monthDate)
                        }
                    }
                )
            }
        }
    }
}

struct ReportPDFShareModifier: ViewModifier {
    let selectedDate: Date
    @State private var isGeneratingPDF = false
    @State private var isShareSheetPresented = false
    @State private var generatedPDFURL: URL?
    @State private var pdfErrorMessage = ""
    @State private var isPDFErrorPresented = false

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isShareSheetPresented) {
                if let generatedPDFURL {
                    ReportShareSheet(fileURL: generatedPDFURL)
                }
            }
            .alert("PDF 생성 실패", isPresented: $isPDFErrorPresented) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(pdfErrorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        generatePDF()
                    } label: {
                        if isGeneratingPDF {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .disabled(isGeneratingPDF)
                    .accessibilityLabel(isGeneratingPDF ? "PDF 생성 중" : "PDF 공유")
                }
            }
    }

    private func generatePDF() {
        guard !isGeneratingPDF else { return }

        isGeneratingPDF = true

        Task {
            defer { isGeneratingPDF = false }

            do {
                let reportData = try await ReportDataLoader.load(date: selectedDate)
                generatedPDFURL = try await ReportPDFGenerator.generate(data: reportData)
                isShareSheetPresented = true
            } catch {
                pdfErrorMessage = error.localizedDescription
                isPDFErrorPresented = true
            }
        }
    }
}

private struct ReportShareSheet: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) { }
}

#Preview {
    TabBar(initialTab: .report)
}
