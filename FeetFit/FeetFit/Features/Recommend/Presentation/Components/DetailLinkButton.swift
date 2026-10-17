import SwiftUI

struct DetailLinkButton: View {
    let title: String
    let url: URL?

    var body: some View {
        Group {
            if let url {
                Link(destination: url) {
                    label
                }
            } else {
                Button(action: {}) {
                    label
                }
                .disabled(true)
                .accessibilityHint("링크가 아직 등록되지 않았습니다.")
            }
        }
        .buttonStyle(.glass)
        .frame(maxWidth: .infinity)
    }

    private var label: some View {
        Text(title)
            .pretendardFont(.Description)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
    }
}
