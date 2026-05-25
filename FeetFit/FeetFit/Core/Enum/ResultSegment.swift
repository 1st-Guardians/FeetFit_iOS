//
//  ResultSegment.swift
//  FeetFit
//
//  Created by 김미주 on 5/21/26.
//

import Foundation

enum ResultSegment: String, CaseIterable, Identifiable {
    case overall = "종합 평가"
    case halluxValgus = "무지외반"
    case athletesFoot = "무좀"
    
    var id: String {
        rawValue
    }
}
