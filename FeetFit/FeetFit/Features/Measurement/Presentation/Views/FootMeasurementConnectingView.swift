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
        VStack(spacing: 0) {
            LoadingMessageView(
                message: viewModel.isLoading ? "기기와 연결 중이에요" : "기기를 연결해 주세요"
            )
            .padding(.bottom, 277)
            
            MainButton(viewModel.isLoading ? "기기 연결 중..." : "기기 연결하기", action: {
                print("기기 연결하기 버튼 클릭")
                viewModel.connectDevice()
            })
            .padding(.horizontal, 18)
            .disabled(viewModel.isLoading)
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                router.reset()
            }
        }
        .onAppear {
            viewModel.onMoveToProgress = {
                router.push(.measurementProgress)
            }
        }
    }
}

#Preview {
    FootMeasurementConnectingView(
        viewModel: FootMeasurementViewModel()
    )
}
