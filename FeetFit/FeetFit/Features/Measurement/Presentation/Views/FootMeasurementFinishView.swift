//
//  FootMeasurementFinishView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementFinishView: View {
    @Environment(NavigationRouter<HomeRoute>.self) private var router
    @Bindable var viewModel: FootMeasurementViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LoadingMessageView(
                message: "데이터 전송이\n완료되었습니다."
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            MainButton("홈으로 돌아가기", action: {
                HapticFeedback.impact()
                viewModel.resetMeasurementState()
                router.reset()
            })
            .padding(.horizontal, 18)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                viewModel.resetMeasurementState()
                router.reset()
            }
        }
    }
}

#Preview {
    FootMeasurementFinishView(
        viewModel: FootMeasurementViewModel()
    )
}
