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
        VStack(spacing: 0) {
            LoadingMessageView(
                message: displayMessage
            )
            .padding(.bottom, 277)

            actionButton
                .padding(.horizontal, 18)

            if let errorDetailText {
                Text(errorDetailText)
                    .pretendardFont(.BlockText)
                    .foregroundStyle(.gray01)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
            }

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToFinish = nil
                viewModel.disconnect()
                router.reset()
            }
        }
        .onAppear {
            viewModel.onMoveToFinish = {
                router.push(.measurementFinish)
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

        return viewModel.measurementStatus?.guideMessage ?? viewModel.measurementStatusText
    }

    private var errorDetailText: String? {
        guard viewModel.measurementStatus == .failed else { return nil }
        return viewModel.errorDetail
    }

    @ViewBuilder
    private var actionButton: some View {
        switch viewModel.measurementStatus {
        case .waitingForPhoto:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "사진 촬영 준비 완료",
                action: {
                    Task { await viewModel.confirmPhotoReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .waitingForEnvironment:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "온습도 측정 준비 완료",
                action: {
                    Task { await viewModel.confirmEnvironmentReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .waitingForPressure:
            MainButton(
                viewModel.isStatusUpdateInFlight ? "요청 중..." : "압력 측정 준비 완료",
                action: {
                    Task { await viewModel.confirmPressureReady() }
                }
            )
            .disabled(viewModel.isStatusUpdateInFlight)

        case .failed:
            MainButton(
                "다시 측정하기",
                action: {
                    viewModel.onMoveToFinish = nil
                    viewModel.disconnect()
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
