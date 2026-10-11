//
//  ReportData.swift
//  FeetFit
//

import Foundation

struct ReportShoeData {
    let brand: String
    let name: String
    let price: Int
    let fitScore: Double
    let imageDataURL: String?
    let description: String
}

struct ReportData {
    let name: String
    let age: Int
    let height: Int
    let measurementDate: String
    let reportNumber: String
    let balanceScore: Int
    let balanceDescription: String
    let leftPressurePercent: Double
    let rightPressurePercent: Double
    let pressureDescription: String
    let leftPressureImageDataURL: String?
    let rightPressureImageDataURL: String?
    let leftFootprintImageDataURL: String?
    let rightFootprintImageDataURL: String?
    let halluxScore: Int
    let halluxDescription: String
    let leftHalluxAngleDegree: Double
    let rightHalluxAngleDegree: Double
    let leftHalluxDescription: String
    let rightHalluxDescription: String
    let leftHalluxImageDataURL: String?
    let rightHalluxImageDataURL: String?
    let skinScore: Int
    let skinDescription: String
    let fungalSuspicionScore: Double
    let skinReactionScore: Double
    let fungalSuspicionDescription: String
    let skinReactionDescription: String
    let skinImageDataURL: String?
    let leftFootLengthMm: Double
    let rightFootLengthMm: Double
    let leftFootWidthMm: Double
    let rightFootWidthMm: Double
    let humidityPercent: Double
    let careTips: [String]
    let footTypeDescription: String
    let recommendedShoes: [ReportShoeData]
}
