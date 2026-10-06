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
    @State private var isGeneratingPDF = false
    @State private var isShareSheetPresented = false
    @State private var generatedPDFURL: URL?
    @State private var pdfErrorMessage = ""
    @State private var isPDFErrorPresented = false

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
            ToolBarCollection.ReportMenu(selection: $selectedMenu)

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    generateTestPDF()
                } label: {
                    if isGeneratingPDF {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isGeneratingPDF)
                .accessibilityLabel(isGeneratingPDF ? "PDF 생성 중" : "PDF 테스트")
            }

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

    private func generateTestPDF() {
        guard !isGeneratingPDF else { return }

        isGeneratingPDF = true

        Task {
            defer { isGeneratingPDF = false }

            do {
                let reportData = ReportData(
                    name: "김미주",
                    age: 24,
                    height: 165,
                    measurementDate: "2026.10.05"
                )

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
