//
//  GradientBoxModifier.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct GradientBoxModifier: ViewModifier {
    private let cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .center)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white)
                    .overlay {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .white.opacity(0.0), location: 0.00),
                                Gradient.Stop(
                                    color: Color(red: 0, green: 0.53, blue: 1).opacity(0.1),
                                    location: 1.00
                                )
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    .shadow(
                        color: Color(red: 0, green: 0.53, blue: 1),
                        radius: 2,
                        x: 0,
                        y: 0
                    )
            }
    }
}

extension View {
    func gradientBoxStyle() -> some View {
        modifier(GradientBoxModifier())
    }
}
