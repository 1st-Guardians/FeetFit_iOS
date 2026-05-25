//
//  HardwarePairingView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI
import Lottie

struct HardwarePairingView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            
            LoadingMessageView(
                message: "하드웨어를\n연결 중이에요."
            )
            
            Spacer()
        }
    }
}

#Preview {
    HardwarePairingView()
}
