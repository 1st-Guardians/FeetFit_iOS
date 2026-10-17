//
//  ShoeSortMenuButton.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeSortMenuButton: View {
    @Binding var selectedSortType: ShoeSortType
    
    var body: some View {
        Picker("신발 정렬", selection: $selectedSortType) {
            ForEach(ShoeSortType.allCases, id: \.self) { type in
                Text(type.rawValue)
                    .tag(type)
                    .pretendardFont(.Description)
            }
        }
        .pickerStyle(.menu)
        .tint(.black01)
    }
}

#Preview {
    ShoeSortMenuButton(selectedSortType: .constant(.fit))
        .padding()
        .background(.gray03)
}
