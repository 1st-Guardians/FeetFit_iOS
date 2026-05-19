//
//  MainButton.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

struct MainButton: View {

    // MARK: - Properties

    private let title: String
    private let action: () -> Void

    @Environment(\.mainButtonSize) private var size
    @Environment(\.isEnabled) private var isEnabled

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            MainButtonContent(title: title, size: size, isEnabled: isEnabled)
                .equatable()
        }
        .glassEffect(.regular.tint(size.backgroundColor(isEnabled: isEnabled)).interactive())
        .foregroundStyle(size.foregroundColor(isEnabled: isEnabled))
    }
}

// MARK: - MainButtonContent (Presenter)

private struct MainButtonContent: View, Equatable {
    let title: String
    let size: MainButtonSize
    let isEnabled: Bool

    static func == (lhs: MainButtonContent, rhs: MainButtonContent) -> Bool {
        lhs.isEnabled == rhs.isEnabled &&
        lhs.title == rhs.title &&
        lhs.size == rhs.size
    }

    var body: some View {
        Text(title)
            .pretendardFont(size.font)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
    }
}

// MARK: - MainButton + AnyMainButton

extension MainButton: AnyMainButton { }

// MARK: - Preview

#Preview("MainButton") {
    struct Preview: View {
        @State private var isEnabled = true

        var body: some View {
            VStack(spacing: 16) {
                MainButton("확인") { }
                    .buttonSize(.big)
                    .disabled(!isEnabled)

                MainButton("확인") { }
                    .buttonSize(.small)
                    .disabled(!isEnabled)

                Button("Toggle Enabled") {
                    isEnabled.toggle()
                }
            }
            .padding()
        }
    }

    return Preview()
}
