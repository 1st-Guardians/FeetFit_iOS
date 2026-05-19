//
//  HomeStatus.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import Foundation

enum HomeStatus {
    case noRecord
    case measuredToday
    case notMeasuredToday
    
    var title: String {
        switch self {
        case .noRecord:
            return "핏핏과 함께 발 건강 측정을 시작해 보세요"
        case .measuredToday:
            return "오늘의 발 상태 분석 결과를 확인해 보세요"
        case .notMeasuredToday:
            return "오늘의 발 상태를 측정해 보세요"
        }
    }
    
    var description: String {
        switch self {
        case .noRecord:
            return "첫 측정을 완료하면\n발 상태 분석과 맞춤 관리 정보를 받을 수 있어요."
        case .measuredToday:
            return "오늘 측정한 결과를 바탕으로\n내 발 건강 상태를 확인할 수 있어요"
        case .notMeasuredToday:
            return "간단한 측정으로 내 발 건강을 파악할 수 있어요"
        }
    }
    
    var buttonText: String {
        switch self {
        case .noRecord, .notMeasuredToday:
            return "바로 측정하러 가기"
        case .measuredToday:
            return "바로 확인하러 가기"
        }
    }
}
