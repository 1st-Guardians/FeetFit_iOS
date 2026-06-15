//
//  FootMeasurementFinishView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementFinishView: View {
    @Environment(NavigationRouter<HomeRoute>.self) private var router
    
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "데이터 전송이\n완료되었습니다"
            )
            .padding(.bottom, 277)
            
            MainButton("홈으로 돌아가기", action: {
                router.reset()
            })
            .padding(.horizontal, 18)
            
            Spacer()
        }
    }
}

#Preview {
    FootMeasurementFinishView()
}
