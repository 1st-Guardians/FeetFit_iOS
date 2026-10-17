import SwiftUI

struct ProductInformationView: View {
    @Environment(\.dismiss) private var dismiss

    let product: ProductInfo

    private var informationItems: [ProductInfo.DetailItem] {
        let productItems: [ProductInfo.DetailItem] = [
            .init(title: "제품명", value: product.name),
            .init(title: "브랜드", value: product.brand)
        ]
        let additionalItems = product.detailItems.isEmpty
            ? [.init(title: "허가 정보", value: "등록된 정보 없음")]
            : product.detailItems
        return productItems + additionalItems
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    productInformation

                    if let url = product.recallSourceURL {
                        DetailLinkButton(title: "회수 정보 출처 확인하기", url: url)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("정보 출처")
                            .pretendardFont(.BlockTitle)
                            .accessibilityAddTraits(.isHeader)

                        Text(product.informationSource ?? "정보 출처가 아직 등록되지 않았어요.")
                            .pretendardFont(.BlockText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            .foregroundStyle(.black01)
            .background(.white)
            .navigationTitle("상세 정보")
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

    private var productInformation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("제품·허가 정보")
                .pretendardFont(.BlockTitle)
                .padding(.leading, 8)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 0) {
                ForEach(informationItems.indices, id: \.self) { index in
                    LabeledContent {
                        Text(informationItems[index].value)
                            .foregroundStyle(.gray01)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Text(informationItems[index].title)
                            .foregroundStyle(.black01)
                    }
                    .pretendardFont(.Description)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(minHeight: 52)

                    if index != informationItems.indices.last {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .mainBoxStyle()
        }
    }
}

#Preview {
    ProductInformationView(product: ProductInfo.samples[0])
}
