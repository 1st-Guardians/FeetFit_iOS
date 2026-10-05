//
//  FootMeasurementConnectingView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementConnectingView: View {
    @Environment(NavigationRouter<HomeRoute>.self) private var router
    @Bindable var viewModel: FootMeasurementViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LoadingMessageView(
                message: displayMessage
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if !viewModel.isLoading {
                MainButton("측정 시작하기", action: {
                    HapticFeedback.impact()
                    print("기기 연결하기 버튼 클릭")
                    viewModel.connectDevice()
                })
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToProgress = nil
                viewModel.disconnect()
                viewModel.resetMeasurementState()
                router.reset()
            }
        }
        .onAppear {
            if !viewModel.isLoading {
                viewModel.resetMeasurementState()
            }
            viewModel.onMoveToProgress = {
                router.push(.measurementProgress)
            }
        }
    }

    private var displayMessage: String {
        if let errorMessage = viewModel.errorMessage {
            return errorMessage
        }

        return viewModel.isLoading ? "기기와 연결 중이에요.\n " : "준비가 되면\n버튼을 눌러주세요."
    }
}

#Preview {
    FootMeasurementConnectingView(
        viewModel: FootMeasurementViewModel()
    )
}
