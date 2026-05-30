//
//  FootSizeTableView.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import SwiftUI

struct FootSizeTableView: View {
    private let rows: [FootSizeRow]

    init(rows: [FootSizeRow]) {
        self.rows = rows
    }

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 0),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            headerCell("")
            headerCell("왼발")
            headerCell("오른발")

            ForEach(rows) { row in
                titleCell(row.title)
                valueCell(value: row.left, diff: row.leftDiff)
                valueCell(value: row.right, diff: row.rightDiff)
            }
        }
        .foregroundStyle(.black01)
    }

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.SectionTitle)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .multilineTextAlignment(.center)
    }

    private func titleCell(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.SectionTitle)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .multilineTextAlignment(.center)
    }

    private func valueCell(value: String, diff: String?) -> some View {
        HStack(spacing: 4) {
            Text(value)

            if let diff {
                Text("(\(diff))")
                    .foregroundStyle(.blue01)
            }
        }
        .pretendardFont(.BlockText)
        .frame(maxWidth: .infinity)
        .frame(height: 30)
    }
}

#Preview {
    FootSizeTableView(
        rows: [
            .init(title: "입력 사이즈", left: "250mm", leftDiff: nil, right: "250mm", rightDiff: nil),
            .init(title: "측정 사이즈", left: "253mm", leftDiff: "+3", right: "248mm", rightDiff: "-2"),
            .init(title: "발볼 너비", left: "85mm", leftDiff: nil, right: "70mm", rightDiff: nil)
        ]
    )
}
