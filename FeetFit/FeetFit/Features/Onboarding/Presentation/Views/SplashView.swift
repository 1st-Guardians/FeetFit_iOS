//
//  SplashView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct SplashView: View {
    let onFinish: () -> Void
    
    var body: some View {
        VStack {
            Image("FeetFit")
                .resizable()
                .frame(width: 171, height: 136)
        }
        .navigationBarBackButtonHidden()
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                onFinish()
            }
        }
    }
}
