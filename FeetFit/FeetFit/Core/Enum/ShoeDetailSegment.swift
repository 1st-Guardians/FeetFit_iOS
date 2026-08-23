//
//  ShoeDetailSegment.swift
//  FeetFit
//

import Foundation

enum ShoeDetailSegment: String, CaseIterable, Identifiable {
    case productInfo = "상품정보"
    case fitScore = "내 발 적합도"
    case compare = "신발비교"

    var id: String {
        rawValue
    }
}
