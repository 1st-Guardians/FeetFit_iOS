//
//  ShoeSearchHistoryDTO.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import Foundation

struct ShoeSearchHistoryResultDTO: Decodable {
    let histories: [ShoeSearchHistoryDTO]
}

struct ShoeSearchHistoryDTO: Identifiable, Decodable {
    let id: Int
    let keyword: String
}
