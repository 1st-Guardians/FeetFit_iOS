import SwiftUI

struct ProductListView: View {
    let products: [ProductInfo]
    var onProductTap: (ProductInfo) -> Void = { _ in }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(products.indices, id: \.self) { index in
                Button {
                    onProductTap(products[index])
                } label: {
                    ProductInfoView(
                        tag: products[index].tag,
                        brand: products[index].brand,
                        name: products[index].name,
                        imageURL: products[index].imageURL
                    )
                }
                .buttonStyle(.plain)

                if index != products.indices.last {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ProductListView(products: ProductInfo.samples)
    }
}
