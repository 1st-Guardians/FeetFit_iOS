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
                message: viewModel.isLoading ? "기기와 연결 중이에요\n " : "기기를 연결해 주세요\n "
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            MainButton(viewModel.isLoading ? "기기 연결 중..." : "기기 연결하기", action: {
                print("기기 연결하기 버튼 클릭")
                viewModel.connectDevice()
            })
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
            .disabled(viewModel.isLoading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.onMoveToProgress = nil
                viewModel.disconnect()
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
