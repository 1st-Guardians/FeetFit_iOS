//
//  FootMeasurementDataExportingView.swift
//  FeetFit
//
//  Created by 이채은 on 5/25/26.
//

import SwiftUI

struct FootMeasurementDataExportingView: View {
    @Environment(NavigationRouter<HomeRoute>.self) private var router

    var body: some View {
        VStack(spacing: 0) {
            LoadingMessageView(
                message: "데이터 보내는 중..."
            )

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                router.reset()
            }
        }
    }
}

#Preview {
    FootMeasurementDataExportingView()
}
