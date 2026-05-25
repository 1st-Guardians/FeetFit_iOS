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
            
            LottieView(animation: .named("FeetFit Loading", bundle: Bundle.main))
                .playing(loopMode: .loop)
                .frame(width: 100, height: 100)
                .padding(.bottom, 10)
                .padding(.top, 217)
            
            Text("하드웨어를\n연결 중이에요.")
                .pretendardFont(.SubTitle)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

#Preview {
    HardwarePairingView()
}
