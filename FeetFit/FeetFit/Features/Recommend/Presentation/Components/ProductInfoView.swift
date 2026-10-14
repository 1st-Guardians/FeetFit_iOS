import SwiftUI

struct ProductInfoView: View {
    let tag: String
    let brand: String
    let name: String
    let imageURL: String

    var body: some View {
        HStack(spacing: 15) {
            productImage

            VStack(alignment: .leading, spacing: 8) {
                Text(tag)
                    .pretendardFont(.Caption)
                    .foregroundStyle(.black01)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Color(red: 75 / 255, green: 184 / 255, blue: 1).opacity(0.2),
                        in: Capsule()
                    )
                    .glassEffect(in: .capsule)

                VStack(alignment: .leading, spacing: 4) {
                    Text(brand)
                        .pretendardFont(.Caption)

                    Text(name)
                        .pretendardFont(.BlockText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var productImage: some View {
        Group {
            if let url = URL(string: imageURL), !imageURL.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 78, height: 78)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } placeholder: {
                    ProgressView()
                        .frame(width: 78, height: 78)
                }
            } else {
                Rectangle()
                    .fill(.white)
                    .overlay {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray02)
                    }
                    .frame(width: 78, height: 78)
            }
        }
        .frame(width: 78, height: 78)
        .mainBoxStyle()
    }
}

#Preview {
    ProductInfoView(
        tag: "발 관리",
        brand: "제작사",
        name: "제품 이름",
        imageURL: ""
    )
}
