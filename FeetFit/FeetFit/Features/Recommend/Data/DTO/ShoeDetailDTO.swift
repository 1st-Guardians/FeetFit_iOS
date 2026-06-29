//
//  ShoeDetailDTO.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation

struct ShoeDetailResultDTO: Decodable {
    let id: Int
    let brandName: String
    let shoeName: String
    let shoeUrl: String
    let price: Int
    let imageUrl: String
    let overallRating: Double
    let clickCount: Int
    let reviewCount: Int
    let fitScore: Double?
    let pointSummary: String?
    let reasons: [ShoeFitReasonDTO]
}

struct ShoeFitReasonDTO: Decodable {
    let reasonType: String
    let title: String
    let riskLevel: String
    let reviewSummary: String
    let reviewTexts: [String]
}

extension ShoeDetailResultDTO {
    func toDomain() -> ShoeDetailInfo {
        let fitPoints = reasons.enumerated().map { index, reason in
            ShoeFitPoint(
                id: index,
                type: reason.reasonType.toFitPointType(),
                status: reason.riskLevel.toMainBoxStatus()
            )
        }
        
        let analysisCards = reasons.enumerated().map { index, reason in
            ShoeFitAnalysis(
                id: index,
                title: reason.title,
                status: reason.riskLevel.toMainBoxStatus(),
                reviewQuotes: reason.reviewTexts,
                description: reason.reviewSummary
            )
        }
        
        return ShoeDetailInfo(
            id: id,
            brand: brandName,
            name: shoeName,
            price: price,
            rating: overallRating,
            fitScore: fitScore,
            interestCount: clickCount,
            reviewCount: reviewCount,
            imageURL: imageUrl,
            shoeURL: shoeUrl,
            summary: pointSummary ?? "아직 사용자 발 분석 기반 착용 포인트가 없습니다.",
            fitPoints: fitPoints,
            analysisCards: analysisCards
        )
    }
}

private extension String {
    func toFitPointType() -> ShoeFitPointType {
        switch self {
        case "FOREFOOT":
            return .width
        case "HEEL":
            return .heel
        case "INSOLE":
            return .insole
        default:
            return .width
        }
    }
    
    func toMainBoxStatus() -> MainBoxStatus {
        switch self {
        case "LOW":
            return .good
        case "MEDIUM":
            return .warn
        case "HIGH":
            return .bad
        default:
            return .good
        }
    }
}
