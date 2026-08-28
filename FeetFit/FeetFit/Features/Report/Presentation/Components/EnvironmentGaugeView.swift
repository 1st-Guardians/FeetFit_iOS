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
    private let beforeValue: Double
    private let afterValue: Double

    init(type: EnvironmentType, value: Double, beforeValue: Double, afterValue: Double) {
        self.type = type
        self.value = value
        self.beforeValue = beforeValue
        self.afterValue = afterValue
    }

    var body: some View {
        HStack(spacing: 16) {
            Text(type.title)
                .pretendardFont(.BlockText)

            ComparisonBar(
                comparisonValue: normalized(beforeValue),
                shoeValue: normalized(afterValue),
                color: type.color,
                fillValue: normalized(afterValue)
            )

            Text("\(Int(value))\(type.unit)")
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
        }
        .foregroundStyle(.black01)
        .frame(height: 50)
    }

    private func normalized(_ rawValue: Double) -> CGFloat {
        CGFloat(min(max(rawValue / type.maxValue, 0), 1))
    }
}

#Preview {
    EnvironmentGaugeView(type: .temperature, value: 34, beforeValue: 28, afterValue: 34)
}
