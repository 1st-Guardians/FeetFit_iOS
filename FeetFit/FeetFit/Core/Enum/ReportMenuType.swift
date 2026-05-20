//
//  ReportMenuType.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import Foundation

enum ReportMenuType: String, CaseIterable, Identifiable {
    case resultReport = "결과 리포트"
    case summary = "요약"
    
    var id: String { rawValue }
}
