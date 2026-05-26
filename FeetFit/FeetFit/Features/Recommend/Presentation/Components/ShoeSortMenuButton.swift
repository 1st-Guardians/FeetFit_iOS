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
        Menu {
            ForEach(ShoeSortType.allCases, id: \.self) { type in
                Button {
                    selectedSortType = type
                } label: {
                    HStack {
                        Text(type.rawValue)
                        
                        if selectedSortType == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedSortType.rawValue)
                    .pretendardFont(.Description)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 11))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .glassEffect(in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ShoeSortMenuButton(selectedSortType: .constant(.fit))
        .padding()
        .background(.gray03)
}
