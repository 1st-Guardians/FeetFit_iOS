//
//  Font.swift
//  FeetFit
//
//  Created by 김미주 on 5/19/26.
//

import SwiftUI

extension Font {
    enum Pretendard {
        case bold
        case semibold
        case medium
        case regular

        var value: String {
            switch self {
            case .bold: "Pretendard-Bold"
            case .semibold: "Pretendard-SemiBold"
            case .medium: "Pretendard-Medium"
            case .regular: "Pretendard-Regular"
            }
        }
    }

    struct PretendardStyle {
        let font: Font
        let lineSpacing: CGFloat

        static var ScoreText: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .semibold, size: 35), lineSpacing: 0)
        }
        static var Title: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .bold, size: 24), lineSpacing: 8)
        }
        static var SubTitle: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .bold, size: 20), lineSpacing: 4)
        }
        static var BlockTitle: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .semibold, size: 18), lineSpacing: 4)
        }
        static var Description: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .medium, size: 16), lineSpacing: 6)
        }
        static var SectionTitle: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .semibold, size: 15), lineSpacing: 0)
        }
        static var Placeholder: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .medium, size: 14), lineSpacing: 0)
        }
        static var BlockText: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .medium, size: 14), lineSpacing: 8)
        }
        static var Caption: PretendardStyle {
            PretendardStyle(font: .pretendard(type: .regular, size: 12), lineSpacing: 3)
        }
    }

    static func pretendard(type: Pretendard, size: CGFloat) -> Font {
        return .custom(type.value, size: size)
    }
}

extension View {
    func pretendardFont(_ style: Font.PretendardStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
    }
}
