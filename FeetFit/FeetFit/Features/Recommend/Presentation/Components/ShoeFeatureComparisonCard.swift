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
        HStack(spacing: 8) {
            Text(feature.title)
                .pretendardFont(.BlockTitle)
                .foregroundStyle(.black01)

            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(feature.levelText)
                    .pretendardFont(.Caption)
                    .foregroundStyle(statusColor)
            }
        }
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
            Text(feature.minimumLabel)
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)

            ComparisonBar(
                comparisonValue: feature.comparisonValue,
                shoeValue: feature.shoeValue
            )

            Text(feature.maximumLabel)
                .pretendardFont(.Caption)
                .foregroundStyle(.gray01)
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

    // MARK: - Helper

    private var statusColor: Color {
        switch feature.levelText {
        case "낮음": return .red01
        case "보통": return .yellow01
        case "높음": return .green01
        default: return .gray01
        }
    }
}

// MARK: - ComparisonBar

/// 0...1 범위의 두 값을 가로 바 위 마커로 비교해서 보여주는 재사용 가능한 그래프.
/// 파란색 채워진 원 = 비교군 평균, 흰색 채움 + 파란색 테두리 원 = 신발 값.
struct ComparisonBar: View {
    let comparisonValue: CGFloat
    let shoeValue: CGFloat

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
                
                marker(filled: false)
                    .offset(x: usableWidth * clamp(shoeValue))

                marker(filled: true)
                    .offset(x: usableWidth * clamp(comparisonValue))
            }
        }
        .frame(height: markerDiameter)
    }

    private func marker(filled: Bool) -> some View {
        Circle()
            .fill(filled ? Color.blue01 : Color.white)
            .overlay(
                Circle().stroke(Color.blue01, lineWidth: markerBorderWidth)
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
