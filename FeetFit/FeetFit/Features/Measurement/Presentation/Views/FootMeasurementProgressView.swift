//
//  FootMeasurementProgressView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementProgressView: View {
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "발 측정 중..."
            )
            
            Spacer()
        }
    }
}

#Preview {
    FootMeasurementProgressView()
}
