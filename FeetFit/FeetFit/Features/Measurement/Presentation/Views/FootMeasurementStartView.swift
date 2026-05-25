//
//  FootMeasurementStartView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//
import SwiftUI

struct FootMeasurementStartView: View {
    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "기기의 안내에 따라\n발 측정을 진행해 주세요"
            )
            
            Spacer()
        }
    }
}

#Preview {
    FootMeasurementStartView()
}
