//
//  FootMeasurementFinishView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementFinishView: View {
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "데이터 전송이\n완료되었습니다"
            )
            .padding(.bottom, 277)
            
            MainButton("결과 확인하기", action: {
                print("결과 확인하기 버튼 클릭")
            })
            .padding(.horizontal, 18)
            
            Spacer()
        }
    }
}

#Preview {
    FootMeasurementFinishView()
}
