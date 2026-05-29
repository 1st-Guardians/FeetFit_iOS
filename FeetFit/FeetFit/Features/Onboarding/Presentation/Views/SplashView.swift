//
//  SplashView.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image("FeetFit")
                .resizable()
                .frame(width: 171, height: 136)
        }
    }
}

#Preview {
    SplashView()
}
