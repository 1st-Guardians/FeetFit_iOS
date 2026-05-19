//
//  StretchingTodo.swift
//  FeetFit
//
//  Created by 김미주 on 5/20/26.
//

import SwiftUI

struct StretchingTodo: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool = false
}
