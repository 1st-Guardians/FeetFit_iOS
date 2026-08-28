//
//  ShoeDetailView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ShoeDetailViewModel
    @State private var selectedSegment: ShoeDetailSegment = .productInfo

    init(shoeId: Int) {
        _viewModel = StateObject(wrappedValue: ShoeDetailViewModel(shoeId: shoeId))
    }

    #if DEBUG
    init(previewShoe: ShoeDetailInfo) {
        _viewModel = StateObject(wrappedValue: ShoeDetailViewModel(mockShoe: previewShoe))
    }
    #endif

    // MARK: - Body

    var body: some View {
        Group {
            if let shoe = viewModel.shoe {
                detailContent(shoe: shoe)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
            } else {
                errorContent
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolBarCollection.BackBtn {
                dismiss()
            }
        }
        .onAppear {
            guard viewModel.shoe == nil else { return }
            viewModel.fetchDetail()
            viewModel.fetchCharacteristics()
        }
    }

    // MARK: - Content

    private func detailContent(shoe: ShoeDetailInfo) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ShoeDetailProductImageView(urlString: shoe.imageURL)

                VStack(alignment: .leading, spacing: 20) {
                    ShoeDetailHeaderView(shoe: shoe)

                    segmentControl
                        .padding(.top, 20)

                    segmentContent(shoe: shoe)
                }
                .padding(.horizontal, 16)
            }
        }
        .ignoresSafeArea()
    }

    private var errorContent: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage ?? "신발 정보를 불러오지 못했습니다.")
                .pretendardFont(.BlockText)
                .foregroundStyle(.gray01)

            Button {
                dismiss()
            } label: {
                Text("돌아가기")
                    .pretendardFont(.BlockText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }

    // MARK: - Segment

    private var segmentControl: some View {
        Picker("상세 정보 탭", selection: $selectedSegment) {
            ForEach(ShoeDetailSegment.allCases) { segment in
                Text(segment.rawValue)
                    .tag(segment)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private func segmentContent(shoe: ShoeDetailInfo) -> some View {
        switch selectedSegment {
        case .productInfo:
            productInfoContent

        case .fitScore:
            fitScoreContent(shoe: shoe)
        }
    }

    // MARK: - 상품 정보

    @ViewBuilder
    private var productInfoContent: some View {
        if viewModel.specProfile != nil || !viewModel.featureComparisons.isEmpty {
            VStack(alignment: .leading, spacing: 32) {
                if let specProfile = viewModel.specProfile {
                    ShoeSpecSummarySection(specProfile: specProfile)
                }

                if !viewModel.featureComparisons.isEmpty {
                    ShoeFeatureComparisonSection(comparisons: viewModel.featureComparisons)
                }
            }
            .padding(.bottom, 100)
        } else {
            segmentPlaceholder("상품정보 페이지를 준비 중이에요.")
        }
    }

    // MARK: - 내 발 적합도

    private func fitScoreContent(shoe: ShoeDetailInfo) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            ShoeFitSummarySection(shoe: shoe)
            ShoeFitScoreSection(shoe: shoe)
        }
    }

    // MARK: - Placeholder

    private func segmentPlaceholder(_ message: String) -> some View {
        Text(message)
            .pretendardFont(.BlockText)
            .foregroundStyle(.gray01)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
}

#Preview {
    NavigationStack {
        ShoeDetailView(previewShoe: .mock)
    }
}
