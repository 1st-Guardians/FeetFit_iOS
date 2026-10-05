//
//  String+CharacterWrapped.swift
//  FeetFit
//

import Foundation

extension String {
    var characterWrapped: String {
        map(String.init).joined(separator: "\u{200B}")
    }
}
