//
//  ShoeDetailSegment.swift
//  FeetFit
//

import Foundation

enum ShoeDetailSegment: String, CaseIterable, Identifiable {
    case productInfo = "상품정보"
    case fitScore = "적합도"

    var id: String {
        rawValue
    }
}
