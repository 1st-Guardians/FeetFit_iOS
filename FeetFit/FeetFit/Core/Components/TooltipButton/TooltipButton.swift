//
//  TooltipButton.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct TooltipButton: View {
    // MARK: - Properties
    
    private let message: String
    private let iconSize: CGFloat
    private let width: CGFloat
    
    @State private var isPresented = false
    
    init(
        message: String,
        iconSize: CGFloat = 15,
        width: CGFloat = 280
    ) {
        self.message = message
        self.iconSize = iconSize
        self.width = width
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: iconSize))
        }
        .popover(isPresented: $isPresented) {
            tooltipContent
                .presentationCompactAdaptation(.popover)
        }
    }
    
    // MARK: - SubView
    
    private var tooltipContent: some View {
        Text(markdownText)
            .pretendardFont(.Caption)
            .foregroundStyle(.black01)
            .lineSpacing(4)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .frame(width: width, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(16)
    }
    
    private var markdownText: AttributedString {
        do {
            return try AttributedString(
                markdown: message,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )
        } catch {
            return AttributedString(message)
        }
    }
}

#Preview {
    TooltipButton(message:
        """
        여기에 내용 쓰기
        """
    )
}
