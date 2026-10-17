import SwiftUI

struct ProductPrecautionsView: View {
    @Environment(\.dismiss) private var dismiss

    let product: ProductInfo

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProductPrecautionGroup(
                        title: "사용 전 확인",
                        text: product.precautions ?? "사용 전 확인 정보가 아직 등록되지 않았어요."
                    )

                    ProductPrecautionGroup(
                        title: "부작용",
                        text: product.sideEffects ?? "부작용 정보가 아직 등록되지 않았어요."
                    )

                    if let interactions = product.interactions {
                        ProductPrecautionGroup(title: "함께 사용 시 주의사항", text: interactions)
                    }
                }
                .padding(20)
            }
            .foregroundStyle(.black01)
            .background(.white)
            .navigationTitle("주의사항")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                    .tint(.black01)
                }
            }
        }
    }
}

private struct ProductPrecautionGroup: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.red01)
                    .accessibilityHidden(true)

                Text(title)
                    .pretendardFont(.BlockTitle)
                    .accessibilityAddTraits(.isHeader)
            }

            Text(text)
                .pretendardFont(.BlockText)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.gray03, in: RoundedRectangle(cornerRadius: 20))
        }
        .foregroundStyle(.black01)
    }
}

#Preview {
    ProductPrecautionsView(product: ProductInfo.samples[0])
}
