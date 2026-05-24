//
//  FootSizeRow.swift
//  FeetFit
//
//  Created by 김미주 on 5/23/26.
//

import Foundation

struct FootSizeRow: Identifiable {
    let id = UUID()
    let title: String
    let left: String
    let leftDiff: String?
    let right: String
    let rightDiff: String?
}
