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
                message: viewModel.measurementStatusText
            )
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
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
}

#Preview {
    FootMeasurementProgressView(
        viewModel: FootMeasurementViewModel()
    )
}
