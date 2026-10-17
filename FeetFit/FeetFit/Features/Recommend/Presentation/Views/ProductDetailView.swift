import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: DrugDetailViewModel
    @State private var presentedSheet: ProductDetailSheet?

    private var product: ProductInfo { viewModel.product }

    init(product: ProductInfo) {
        _viewModel = StateObject(wrappedValue: DrugDetailViewModel(product: product))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                productImage

                VStack(alignment: .leading, spacing: 32) {
                    titleSection

                    if viewModel.isLoading {
                        ProgressView("상세 정보를 불러오는 중이에요.")
                            .frame(maxWidth: .infinity)
                    } else if let message = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(message)
                                .pretendardFont(.BlockText)
                                .multilineTextAlignment(.center)
                            Button("다시 시도") { viewModel.fetchDetail() }
                                .tint(.blue01)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        DetailLinkButton(title: "공식 정보 확인하기", url: product.officialURL)

                        informationSection

                        detailList
                    }
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
        .task {
            viewModel.fetchDetail()
        }
        .sheet(item: $presentedSheet) { sheet in
            Group {
                switch sheet {
                case .precautions:
                    ProductPrecautionsView(product: product)
                case .information:
                    ProductInformationView(product: product)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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
                ProductDetailActionRow(
                    title: "주의사항",
                    systemImage: "exclamationmark.circle.fill",
                    iconColor: .red01
                ) {
                    presentedSheet = .precautions
                }

                ProductDetailActionRow(
                    title: "상세 정보",
                    systemImage: "info.circle.fill",
                    iconColor: .blue01
                ) {
                    presentedSheet = .information
                }
                .listRowSeparator(.hidden, edges: .bottom)
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 60)
        .contentMargins(.all, 0, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .frame(height: 120)
        .mainBoxStyle()
    }
}

private enum ProductDetailSheet: String, Identifiable {
    case precautions
    case information

    var id: Self { self }
}

private struct ProductDetailActionRow: View {
    let title: String
    let systemImage: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: systemImage)
                        .foregroundStyle(iconColor)
                }
                .pretendardFont(.BlockTitle)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: 60)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: ProductInfo.samples[0])
    }
}
