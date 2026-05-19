//
//  LinearGradient.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct BlueLinearModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .blue02, location: 0.00),
                        Gradient.Stop(color: Color(red: 0.8, green: 0.92, blue: 1), location: 0.64),
                        Gradient.Stop(color: .white, location: 0.90),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
    }
}

extension View {
    func blueLinear() -> some View {
        modifier(BlueLinearModifier())
    }
}
