//
//  HardwarePairingFinishView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI
import Lottie

struct HardwarePairingFinishView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            LoadingMessageView(
                message: "하드웨어 연결이 완료되었어요\n핏핏으로 가볼까요?"
            )
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                onFinish()
            }
        }
    }
}
