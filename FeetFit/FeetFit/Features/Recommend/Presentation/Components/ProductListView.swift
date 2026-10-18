import SwiftUI

struct ProductListView: View {
    let products: [ProductInfo]
    var onProductTap: (ProductInfo) -> Void = { _ in }
    var onProductAppear: (ProductInfo) -> Void = { _ in }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(products) { product in
                Button {
                    onProductTap(product)
                } label: {
                    ProductInfoView(
                        tag: product.tag,
                        brand: product.brand,
                        name: product.name,
                        imageURL: product.imageURL
                    )
                }
                .buttonStyle(.plain)
                .task(id: products.count) { onProductAppear(product) }

                if product.id != products.last?.id {
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
