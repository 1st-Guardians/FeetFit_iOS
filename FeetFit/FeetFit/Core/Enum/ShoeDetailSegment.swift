//
//  ShoeDetailSegment.swift
//  FeetFit
//

import Foundation

enum ShoeDetailSegment: String, CaseIterable, Identifiable {
    case fitScore = "적합도"
    case productInfo = "상품정보"

    var id: String {
        rawValue
    }
}
