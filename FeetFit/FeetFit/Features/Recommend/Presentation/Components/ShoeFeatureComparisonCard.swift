//
//  ShoeFeatureComparisonCard.swift
//  FeetFit
//

import SwiftUI

struct ShoeFeatureComparisonCard: View {
    let feature: ShoeFeatureComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            description
            comparisonSection
            legend

            if let note = feature.note {
                Text(note)
                    .pretendardFont(.Caption)
                    .foregroundStyle(.gray01)
            }
        }
        .padding(24)
        .mainBoxStyle()
    }

    // MARK: - SubViews

    private var header: some View {
        Text(feature.title)
            .pretendardFont(.BlockTitle)
            .foregroundStyle(.black01)
    }

    private var description: some View {
        Text(feature.description)
            .pretendardFont(.BlockText)
            .foregroundStyle(.black01)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var comparisonSection: some View {
        HStack(spacing: 12) {
            if showsScaleLabels {
                Text(feature.minimumLabel)
                    .pretendardFont(.Caption)
                    .foregroundStyle(.gray01)
            }

            ComparisonBar(
                comparisonValue: feature.comparisonValue,
                shoeValue: feature.shoeValue
            )

            if showsScaleLabels {
                Text(feature.maximumLabel)
                    .pretendardFont(.Caption)
                    .foregroundStyle(.gray01)
            }
        }
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 8) {
            legendItem(filled: true, text: "현재 신발")
            legendItem(filled: false, text: "비교군 평균")
        }
    }

    private func legendItem(filled: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(filled ? Color.blue01 : Color.white)
                .overlay(
                    Circle().stroke(Color.blue01, lineWidth: 1)
                )
                .frame(width: 8, height: 8)

            Text(text)
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
        }
    }

    private var showsScaleLabels: Bool {
        feature.minimumLabel != "낮음" && feature.maximumLabel != "높음"
    }

}

// MARK: - ComparisonBar

/// 0...1 범위의 두 값을 가로 바 위 마커로 비교해서 보여주는 재사용 가능한 그래프.
/// 채워진 원 = 신발(현재) 값, 흰색 채움 + 테두리만 있는 원 = 비교군(이전) 평균.
struct ComparisonBar: View {
    let comparisonValue: CGFloat
    let shoeValue: CGFloat
    var color: Color = .blue01
    /// 지정하면 트랙 왼쪽부터 이 값 위치까지 색이 채워진 바를 함께 표시한다 (기본은 표시 안 함).
    var fillValue: CGFloat? = nil

    private let trackHeight: CGFloat = 6
    private let markerDiameter: CGFloat = 16
    private let markerBorderWidth: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let usableWidth = max(geometry.size.width - markerDiameter, 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray03)
                    .frame(height: trackHeight)
                    .frame(maxWidth: .infinity)

                if let fillValue {
                    Capsule()
                        .fill(color)
                        .frame(
                            width: markerDiameter / 2 + usableWidth * clamp(fillValue),
                            height: trackHeight
                        )
                }

                marker(filled: false)
                    .offset(x: usableWidth * clamp(comparisonValue))

                marker(filled: true)
                    .offset(x: usableWidth * clamp(shoeValue))
            }
        }
        .frame(height: markerDiameter)
    }

    private func marker(filled: Bool) -> some View {
        Circle()
            .fill(filled ? color : Color.white)
            .overlay(
                Circle().stroke(color, lineWidth: markerBorderWidth)
            )
            .frame(width: markerDiameter, height: markerDiameter)
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }
}

// MARK: - ShoeFeatureComparisonSection

struct ShoeFeatureComparisonSection: View {
    let comparisons: [ShoeFeatureComparison]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("신발 특성 상세")
                .pretendardFont(.SubTitle)
                .padding(.leading, 8)

            VStack(spacing: 16) {
                ForEach(comparisons) { feature in
                    ShoeFeatureComparisonCard(feature: feature)
                }
            }
        }
        .foregroundStyle(.black01)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(ShoeFeatureComparison.samples) { feature in
                ShoeFeatureComparisonCard(feature: feature)
            }
        }
        .padding(16)
    }
    .background(Color.gray03.opacity(0.3))
}
