//
//  SelectButton.swift
//  FeetFit
//
//  Created by 이채은 on 5/21/26.
//

import SwiftUI

struct SelectButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .pretendardFont(.Placeholder)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(isSelected ? Color.blue01 : Color.white)
                .foregroundStyle(isSelected ? Color.white : Color.gray02)
                .mainBoxStyle()
        }
        .buttonStyle(.plain)
    }
}
