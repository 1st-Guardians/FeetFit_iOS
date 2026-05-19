//
//  RadarChartView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

// MARK: - Model

struct RadarChartItem: Identifiable {
    let id = UUID()
    let title: String
    let value: Double
    
    /// value는 0.0 ~ 1.0 사이로 보정해서 사용
    var normalizedValue: Double {
        min(max(value, 0.0), 1.0)
    }
}

// MARK: - RadarChartView

struct RadarChartView: View {
    
    // MARK: - Properties
    
    private let items: [RadarChartItem]
    private let maxLevel: Int
    
    init(
        items: [RadarChartItem],
        maxLevel: Int = 5
    ) {
        self.items = items
        self.maxLevel = maxLevel
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2
            )
            
            let radius = size * 0.37
            
            ZStack {
                gridView(
                    center: center,
                    radius: radius
                )
                
                axisView(
                    center: center,
                    radius: radius
                )
                
                dataShapeView(
                    center: center,
                    radius: radius
                )
                
                labelView(
                    center: center,
                    radius: radius
                )
            }
        }
        .frame(height: 330)
    }
}

// MARK: - SubViews

private extension RadarChartView {
    
    func gridView(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(1...maxLevel, id: \.self) { level in
                let levelRadius = radius * CGFloat(level) / CGFloat(maxLevel)
                
                Path { path in
                    guard items.count >= 3 else { return }
                    
                    for index in items.indices {
                        let point = point(
                            at: index,
                            value: 1.0,
                            center: center,
                            radius: levelRadius
                        )
                        
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                    
                    path.closeSubpath()
                }
                .stroke(
                    Color.gray02,
                    lineWidth: 0.5
                )
            }
        }
    }
    
    func axisView(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                Path { path in
                    path.move(to: center)
                    path.addLine(
                        to: point(
                            at: index,
                            value: 1.0,
                            center: center,
                            radius: radius
                        )
                    )
                }
                .stroke(
                    Color.gray02,
                    lineWidth: 0.5
                )
            }
        }
    }
    
    func dataShapeView(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            Path { path in
                guard items.count >= 3 else { return }
                
                for index in items.indices {
                    let point = point(
                        at: index,
                        value: items[index].normalizedValue,
                        center: center,
                        radius: radius
                    )
                    
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                
                path.closeSubpath()
            }
            .fill(Color.blue02.opacity(0.25))
            
            Path { path in
                guard items.count >= 3 else { return }
                
                for index in items.indices {
                    let point = point(
                        at: index,
                        value: items[index].normalizedValue,
                        center: center,
                        radius: radius
                    )
                    
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                
                path.closeSubpath()
            }
            .stroke(
                Color.blue01,
                lineWidth: 2
            )
            
            ForEach(items.indices, id: \.self) { index in
                let point = point(
                    at: index,
                    value: items[index].normalizedValue,
                    center: center,
                    radius: radius
                )
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 5, height: 5)
                    .position(point)
            }
        }
    }
    
    func labelView(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                let labelPoint = point(
                    at: index,
                    value: 1.2,
                    center: center,
                    radius: radius
                )
                
                VStack(spacing: 2) {
                    Text(items[index].title)
                        .pretendardFont(.Caption)
                        .foregroundStyle(.black01)
                    
                    Text("\(Int(items[index].normalizedValue * 100))")
                        .pretendardFont(.Caption)
                        .foregroundStyle(.gray02)
                }
                .multilineTextAlignment(.center)
                .position(labelPoint)
            }
        }
    }
}

// MARK: - Calculate

private extension RadarChartView {
    
    func point(
        at index: Int,
        value: Double,
        center: CGPoint,
        radius: CGFloat
    ) -> CGPoint {
        guard items.count > 0 else { return center }
        
        let angle = angle(at: index)
        let distance = radius * CGFloat(value)
        
        let x = center.x + cos(angle) * distance
        let y = center.y + sin(angle) * distance
        
        return CGPoint(x: x, y: y)
    }
    
    func angle(at index: Int) -> CGFloat {
        let angle = (Double(index) / Double(items.count)) * 2 * Double.pi
        
        // 첫 번째 항목이 위쪽에서 시작하도록 -90도 회전
        return CGFloat(angle - Double.pi / 2)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        RadarChartView(
            items: [
                RadarChartItem(title: "압력 균형", value: 0.8),
                RadarChartItem(title: "무좀", value: 0.65),
                RadarChartItem(title: "환경 상태", value: 0.45),
                RadarChartItem(title: "발냄새", value: 0.72),
                RadarChartItem(title: "무지외반", value: 0.9)
            ]
        )
        .padding()
    }
}
