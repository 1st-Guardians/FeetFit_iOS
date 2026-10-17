//
//  FootMeasurementProgressView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementProgressView: View {
    @Environment(NavigationRouter<HomeRoute>.self) private var router
    @Bindable var viewModel: FootMeasurementViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    LoadingMessageView(
                        message: displayMessage,
                        bottomPadding: 10,
                        messageLineLimit: nil
                    )

                    if let errorDetailText {
                        Text(errorDetailText)
                            .pretendardFont(.BlockText)
                            .foregroundStyle(.gray01)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            actionButton
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToFinish = nil
                viewModel.disconnect()
                viewModel.resetMeasurementState()
                router.reset()
            }
        }
        .onAppear {
            viewModel.onMoveToFinish = {
                let reportDate = Date()
                viewModel.onMoveToFinish = nil
                viewModel.resetMeasurementState()
                router.replace(with: .report(reportDate))
            }
        }
        .task {
            print("ProgressView 진입 → 측정 세션 생성 시작")
            await viewModel.startMeasurementSessionIfNeeded()
        }
    }

    // MARK: - SubView

    private var displayMessage: String {
        if viewModel.measurementStatus == .failed, let errorMessage = viewModel.errorMessage {
            return errorMessage
        }

        if viewModel.measurementStatus == .waitingForRecapture || viewModel.measurementStatus == .waitingForPressureRetry {
            return viewModel.measurementStatusText
        }

        return viewModel.measurementStatus?.guideMessage ?? viewModel.measurementStatusText
    }

    private var errorDetailText: String? {
        guard viewModel.measurementStatus == .failed else { return nil }
        return viewModel.errorDetail
    }

    @ViewBuilder
    private var actionButton: some View {
        switch viewModel.measurementStatus {
        case .waitingForPhotoEnvironment:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "측정 준비 완료",
                action: {
                    HapticFeedback.impact()
                    Task { await viewModel.confirmPhotoEnvironmentReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .waitingForPressure:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "측정 준비 완료",
                action: {
                    HapticFeedback.impact()
                    Task { await viewModel.confirmPressureReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .waitingForRecapture:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "다시 촬영하기",
                action: {
                    HapticFeedback.impact()
                    Task { await viewModel.confirmRecaptureReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .readyForRecapture:
            MainButton("재촬영 준비 중...", action: {})
                .disabled(true)

        case .waitingForPressureRetry:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "압력 재측정 준비 완료",
                action: {
                    HapticFeedback.impact()
                    Task { await viewModel.confirmPressureRetryReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .readyForPressureRetry:
            MainButton("압력 재측정 준비 중...", action: {})
                .disabled(true)

        case .failed:
            MainButton(
                "다시 측정하기",
                action: {
                    HapticFeedback.impact()
                    viewModel.onMoveToFinish = nil
                    viewModel.disconnect()
                    viewModel.resetMeasurementState()
                    router.replace(with: .measurement)
                }
            )

        default:
            EmptyView()
        }
    }
}

#Preview {
    FootMeasurementProgressView(
        viewModel: FootMeasurementViewModel()
    )
}
