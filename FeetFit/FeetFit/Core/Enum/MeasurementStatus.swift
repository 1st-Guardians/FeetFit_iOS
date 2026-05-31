//
//  MeasurementStatus.swift
//  FeetFit
//
//  Created by 김미주 on 6/1/26.
//

import Foundation

enum MeasurementStatus: String, Decodable {
    case pending = "PENDING"
    case measuring = "MEASURING"
    case transferring = "TRANSFERRING"
    case completed = "COMPLETED"
    case failed = "FAILED"
}
