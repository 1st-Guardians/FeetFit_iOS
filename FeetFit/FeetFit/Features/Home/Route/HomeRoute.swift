//
//  HomeRoute.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import Foundation

enum HomeRoute: Hashable {
    case main
    case measurement
    case measurementProgress
    case hardwarePairing
    case report(Date)
    case shoeDetail(shoeId: Int)
}
