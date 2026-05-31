//
//  YearChartView.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI
import Charts

struct YearChartView: View {
    let chartData: [YearScore]

    var body: some View {
        Chart(chartData) { data in
            AreaMark(
                x: .value("월", data.month),
                y: .value("점수", data.score)
            )
            .foregroundStyle(.clear)

            LineMark(
                x: .value("월", data.month),
                y: .value("점수", data.score)
            )
            .foregroundStyle(.blue01)
            .lineStyle(
                StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round,
                    lineJoin: .round
                )
            )

            PointMark(
                x: .value("월", data.month),
                y: .value("점수", data.score)
            )
            .foregroundStyle(.blue01)
            .symbolSize(45)
        }
        .frame(height: 220)
        .chartYScale(domain: 50...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [50, 60, 70, 80, 90, 100]) { value in
                AxisGridLine()
                    .foregroundStyle(.gray02)

                AxisValueLabel {
                    if let score = value.as(Int.self) {
                        Text("\(score)")
                            .pretendardFont(.Caption)
                            .foregroundStyle(.black01)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: chartData.map { $0.month }) { value in
                AxisGridLine()
                    .foregroundStyle(.gray02)

                AxisValueLabel {
                    if let month = value.as(String.self) {
                        Text(month)
                            .pretendardFont(.Caption)
                            .foregroundStyle(.black01)
                    }
                }
            }
        }
    }
}

#Preview {
    YearChartView(
        chartData: [
            YearScore(month: "1월", score: 75),
            YearScore(month: "2월", score: 78),
            YearScore(month: "3월", score: 80),
            YearScore(month: "4월", score: 83)
        ]
    )
}
