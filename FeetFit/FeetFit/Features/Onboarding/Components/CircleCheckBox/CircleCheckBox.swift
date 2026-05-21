//
//  CircleCheckBox.swift
//  FeetFit
//
//  Created by 이채은 on 5/21/26.
//

import SwiftUI

struct CircleCheckbox: View {
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .stroke(isChecked ? Color.blue01 : Color.gray02, lineWidth: 1.5)
                    .frame(width: 20, height: 20)

                if isChecked {
                    Circle()
                        .fill(Color.blue01)
                        .frame(width: 20, height: 20)

                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}


