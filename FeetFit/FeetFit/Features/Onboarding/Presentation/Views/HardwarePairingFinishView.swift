//
//  HardwarePairingFinishView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI
import Lottie

struct HardwarePairingFinishView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            
            LoadingMessageView(
                message: "하드웨어 연결이 완료되었어요\n핏핏으로 가볼까요?"
            )
            
            Spacer()
        }
    }
}

#Preview {
    HardwarePairingFinishView()
}
