//
//  GaugeView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct GaugeView: View {
    private let type: GaugeType
    private let current: CGFloat
    private let minValue: CGFloat
    private let maxValue: CGFloat
    private let unit: String
    
    private let lineWidth: CGFloat = 15
    
    init(
        type: GaugeType,
        current: CGFloat,
        minValue: CGFloat,
        maxValue: CGFloat,
        unit: String
    ) {
        self.type = type
        self.current = current
        self.minValue = minValue
        self.maxValue = maxValue
        self.unit = unit
    }
    
    private var progress: CGFloat {
        guard maxValue > minValue else { return 0 }
        let value = (current - minValue) / (maxValue - minValue)
        return min(max(value, 0), 1)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                let center = CGPoint(x: width / 2, y: height - 4)
                let radius = min(width / 2, height) - lineWidth / 2 - 10
                
                ZStack {
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(180),
                            endAngle: .degrees(0),
                            clockwise: false
                        )
                    }
                    .stroke(
                        Color.gray.opacity(0.12),
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .butt
                        )
                    )
                    
                    Path { path in
                        path.addArc(
                            center: center,
                            radius: radius,
                            startAngle: .degrees(180),
                            endAngle: .degrees(0),
                            clockwise: false
                        )
                    }
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .butt
                        )
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: type.colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 21, height: 21)
                        .shadow(color: .black.opacity(0.18), radius: 5, x: 0, y: 2)
                        .position(
                            pointOnArc(
                                value: current,
                                center: center,
                                radius: radius
                            )
                        )
                    
                    HStack(alignment: unit == "º" ? .top : .bottom, spacing: 2) {
                        Text("\(current, specifier: "%.2f")")
                            .pretendardFont(.ScoreText)
                        
                        Text(unit)
                            .pretendardFont(.SectionTitle)
                            .padding(.bottom, 8)
                    }
                    .offset(y: 20)
                    .foregroundStyle(.black01)
                }
            }
            .frame(width: 260, height: 130)
        }
    }
    
    private func pointOnArc(value: CGFloat, center: CGPoint, radius: CGFloat) -> CGPoint {
        let clampedValue = min(max(value, minValue), maxValue)
        let ratio = (clampedValue - minValue) / (maxValue - minValue)
        
        let angle = Double(180 * (1 - ratio))
        let radians = angle * .pi / 180
        
        let x = center.x + cos(radians) * radius
        let y = center.y - sin(radians) * radius
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - 반원
struct SemiCircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width / 2, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

#Preview {
    VStack {
        GaugeView(
            type: .greenToRed,
            current: 12,
            minValue: 0,
            maxValue: 40,
            unit: "ppm"
        )
        .padding()
    }
}
