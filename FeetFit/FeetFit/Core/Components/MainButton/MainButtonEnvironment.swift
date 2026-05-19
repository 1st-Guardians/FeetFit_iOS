//
//  MainButtonEnvironment.swift
//  FeetFit
//
//  Created by 김미주 on 5/18/26.
//

import SwiftUI

// MARK: - Enum

enum MainButtonSize {
    case small
    case big

    var height: CGFloat {
        switch self {
        case .small: return 50
        case .big: return 60
        }
    }

    var font: Font.PretendardStyle {
        switch self {
        case .small: return .Placeholder
        case .big: return .BlockTitle
        }
    }

    func backgroundColor(isEnabled: Bool) -> Color {
        guard isEnabled else {
            switch self {
            case .small: return .white
            case .big: return Color("gray03")
            }
        }
        return Color("blue01")
    }

    func foregroundColor(isEnabled: Bool) -> Color {
        isEnabled ? .white : Color("gray02")
    }
}

// MARK: - Environment Key

struct MainButtonSizeKey: EnvironmentKey {
    static let defaultValue: MainButtonSize = .big
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var mainButtonSize: MainButtonSize {
        get { self[MainButtonSizeKey.self] }
        set { self[MainButtonSizeKey.self] = newValue }
    }
}

// MARK: - AnyMainButton Protocol

protocol AnyMainButton: View { }

// MARK: - ViewModifier

struct MainButtonSizeModifier: ViewModifier {
    let size: MainButtonSize

    func body(content: Content) -> some View {
        content.environment(\.mainButtonSize, size)
    }
}

// MARK: - AnyMainButton Extension

extension AnyMainButton {
    func buttonSize(_ size: MainButtonSize) -> some View {
        self.modifier(MainButtonSizeModifier(size: size))
    }
}
