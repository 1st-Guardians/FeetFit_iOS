//
//  LoadingMessage.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI
import Lottie

struct LoadingMessageView: View {
    
    // MARK: - Properties
    
    private let lottieName: String
    private let message: String
    private let lottieSize: CGFloat
    private let topPadding: CGFloat
    private let bottomPadding: CGFloat
    
    init(
        lottieName: String = "FeetFit Loading",
        message: String,
        lottieSize: CGFloat = 100,
        topPadding: CGFloat = 217,
        bottomPadding: CGFloat = 10
    ) {
        self.lottieName = lottieName
        self.message = message
        self.lottieSize = lottieSize
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            LottieView(animation: .named(lottieName, bundle: Bundle.main))
                .playing(loopMode: .loop)
                .frame(width: lottieSize, height: lottieSize)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            
            Text(message)
                .pretendardFont(.SubTitle)
                .multilineTextAlignment(.center)
        }
    }
}
