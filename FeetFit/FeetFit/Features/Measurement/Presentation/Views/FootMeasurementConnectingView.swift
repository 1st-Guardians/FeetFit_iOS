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
        MeasurementGuideView(guide: guide) {
            HapticFeedback.impact()
            viewModel.connectDevice()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToProgress = nil
                viewModel.disconnect()
                viewModel.resetMeasurementState()
                withTransaction(\.disablesAnimations, true) {
                    router.reset()
                }
            }
        }
        .onAppear {
            if !viewModel.isLoading {
                viewModel.resetMeasurementState()
            }
            viewModel.onMoveToProgress = {
                withTransaction(\.disablesAnimations, true) {
                    router.push(.measurementProgress)
                }
            }
        }
    }

    private var guide: MeasurementGuide {
        if viewModel.errorMessage != nil { return .failed }
        return viewModel.isLoading ? .connecting : .preparation
    }
}

#Preview {
    FootMeasurementConnectingView(
        viewModel: FootMeasurementViewModel()
    )
}
