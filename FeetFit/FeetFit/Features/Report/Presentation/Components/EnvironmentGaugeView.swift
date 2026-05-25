//
//  EnvironmentGaugeView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct EnvironmentGaugeView: View {
    private let type: EnvironmentType
    private let value: Double
    
    init(type: EnvironmentType, value: Double) {
        self.type = type
        self.value = value
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(type.title)
                .pretendardFont(.BlockText)
            
            Gauge(value: value, in: 0...type.maxValue) {
                EmptyView()
            }
            .tint(type.color)
            .scaleEffect(x: 1, y: 0.7, anchor: .center)
            
            Text("\(Int(value))\(type.unit)")
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
        }
        .foregroundStyle(.black01)
        .frame(height: 50)
    }
}

#Preview {
    EnvironmentGaugeView(type: .temperature, value: 34)
}
