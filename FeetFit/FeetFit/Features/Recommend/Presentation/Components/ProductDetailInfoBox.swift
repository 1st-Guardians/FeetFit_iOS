import SwiftUI

struct ProductDetailInfoBox: View {
    let systemImage: String
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundStyle(.blue01)
                    .accessibilityHidden(true)

                Text(title)
                    .pretendardFont(.SubTitle)
            }

            Text(text)
                .pretendardFont(.BlockText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(.black01)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .mainBoxStyle()
    }
}
