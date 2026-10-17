import SwiftUI

struct ProductDetailView: View {
    let product: ProductInfo

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                productImage

                VStack(alignment: .leading, spacing: 32) {
                    titleSection

                    DetailLinkButton(title: "공식 정보 확인하기", url: product.officialURL)

                    informationSection

                    detailList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .foregroundStyle(.black01)
        .background(.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn()
        }
    }

    @ViewBuilder
    private var productImage: some View {
        if !product.imageURL.isEmpty, let url = URL(string: product.imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel("\(product.name) 제품 이미지")

                case .empty:
                    imagePlaceholder
                        .overlay { ProgressView() }

                case .failure:
                    imagePlaceholder

                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(.gray03)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: "shippingbox")
                    .font(.system(size: 70))
                    .foregroundStyle(.gray01)
            }
            .accessibilityLabel("제품 이미지가 없습니다.")
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !product.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(product.tags.indices, id: \.self) { index in
                            Text(product.tags[index])
                                .pretendardFont(.BlockText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .glassEffect(
                                    .regular.tint(Color(red: 219 / 255, green: 241 / 255, blue: 1)),
                                    in: .capsule
                                )
                        }
                    }
                }
                .scrollClipDisabled()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .pretendardFont(.BlockText)

                Text(product.name)
                    .pretendardFont(.Title)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var informationSection: some View {
        VStack(spacing: 32) {
            ProductDetailInfoBox(
                systemImage: "sparkles",
                title: "효능•효과",
                text: product.effects ?? "효능•효과 정보가 아직 등록되지 않았어요."
            )

            ProductDetailInfoBox(
                systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                title: "사용 방법",
                text: product.usage ?? "사용 방법이 아직 등록되지 않았어요."
            )

            ProductDetailInfoBox(
                systemImage: "archivebox.fill",
                title: "보관 방법",
                text: product.storage ?? "보관 방법이 아직 등록되지 않았어요."
            )
        }
    }

    private var detailList: some View {
        List {
            Section {
                NavigationLink {
                    ProductDetailTextView(
                        title: "주의사항",
                        text: product.precautions ?? "주의사항이 아직 등록되지 않았어요."
                    )
                } label: {
                    Label {
                        Text("주의사항")
                    } icon: {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red01)
                    }
                    .pretendardFont(.BlockTitle)
                }

                NavigationLink {
                    ProductDetailTextView(
                        title: "상세 정보",
                        text: product.details ?? "상세 정보가 아직 등록되지 않았어요."
                    )
                } label: {
                    Label {
                        Text("상세 정보")
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue01)
                    }
                    .pretendardFont(.BlockTitle)
                }
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 60)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .contentMargins(.all, 0, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .frame(height: 120)
        .mainBoxStyle()
    }
}

private struct ProductDetailTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .pretendardFont(.BlockText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .foregroundStyle(.black01)
        .background(.white)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn()
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: ProductInfo.samples[0])
    }
}
