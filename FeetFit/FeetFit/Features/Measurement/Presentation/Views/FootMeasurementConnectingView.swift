//
//  FootMeasurementConnectingView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementConnectingView: View {
    private let socketManager = MeasurementSocketManager()
    
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "기기를 연결해 주세요"
            )
            .padding(.bottom, 277)
            
            MainButton("기기 연결하기", action: {
                print("기기 연결하기 버튼 클릭")
                socketManager.connect()
            })
            .padding(.horizontal, 18)
            
            Spacer()
        }
    }
}

#Preview {
    FootMeasurementConnectingView()
}
