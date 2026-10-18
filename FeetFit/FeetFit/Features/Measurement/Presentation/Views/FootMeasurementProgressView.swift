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
        MeasurementGuideView(
            guide: guide,
            isActionInFlight: viewModel.isStatusUpdateInFlight,
            action: handleAction
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToFinish = nil
                viewModel.disconnect()
                viewModel.resetMeasurementState()
                withTransaction(\.disablesAnimations, true) {
                    router.reset()
                }
            }
        }
        .onAppear {
            viewModel.onMoveToFinish = {
                let reportDate = Date()
                viewModel.onMoveToFinish = nil
                viewModel.resetMeasurementState()
                withTransaction(\.disablesAnimations, true) {
                    router.replace(with: .report(reportDate))
                }
            }
        }
        .task {
            print("ProgressView 진입 → 측정 세션 생성 시작")
            await viewModel.startMeasurementSessionIfNeeded()
        }
    }

    private var guide: MeasurementGuide {
        MeasurementGuide(
            status: viewModel.measurementStatus,
            isPhotoRecapture: viewModel.isPhotoRecapture || (viewModel.photoCaptureAttempt ?? 0) > 1
        )
    }

    private func handleAction() {
        HapticFeedback.impact()
        switch viewModel.measurementStatus {
        case .waitingForPhotoEnvironment:
            Task { await viewModel.confirmPhotoEnvironmentReady() }
        case .waitingForPressure:
            Task { await viewModel.confirmPressureReady() }
        case .waitingForRecapture:
            Task { await viewModel.confirmRecaptureReady() }
        case .waitingForPressureRetry:
            Task { await viewModel.confirmPressureRetryReady() }
        case .failed:
            viewModel.onMoveToFinish = nil
            viewModel.disconnect()
            viewModel.resetMeasurementState()
            withTransaction(\.disablesAnimations, true) {
                router.replace(with: .measurement)
            }
        default:
            break
        }
    }
}

#Preview {
    FootMeasurementProgressView(
        viewModel: FootMeasurementViewModel()
    )
}
