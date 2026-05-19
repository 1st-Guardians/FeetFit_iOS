//
//  MainBoxModifier.swift
//  FeetFit
//
//  Created by 김미주 on 5/19/26.
//

import SwiftUI

struct MainBoxModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 4)
    }
}

extension View {
    func mainBoxStyle() -> some View {
        modifier(MainBoxModifier())
    }
}
