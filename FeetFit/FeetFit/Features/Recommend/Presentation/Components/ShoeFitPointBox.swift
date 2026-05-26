//
//  ShoeFitPointBox.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeFitPointBox: View {
    let point: ShoeFitPoint
    
    var body: some View {
        VStack(spacing: 8) {
            icon
            
            Text(point.type.rawValue)
                .pretendardFont(.BlockText)
                .foregroundStyle(.white)
        }
        .frame(width: 100, height: 100)
        .frame(width: 100, height: 100)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(point.status.color)
                .shadow(color: .gray03, radius: 7, x: 2, y: 2)
        }
        
    }
    
    private var icon: some View {
        ZStack {
            switch point.status {
            case .good:
                Circle()
                    .fill(.white)
                    .frame(width: 46, height: 46)
                
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .frame(width: 18, height: 18)
                    .foregroundStyle(point.status.color)
                
            case .warn:
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                
                Image(systemName: "exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(point.status.color)
                    .frame(width: 6, height: 24)
                    .offset(y: 3)
                
            case .bad:
                Image(systemName: "seal.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.bold)
                    .foregroundStyle(point.status.color)
                    .frame(width: 18, height: 18)
                
            case .none:
                EmptyView()
            }
        }
        .frame(height: 52)
    }
}

#Preview {
    HStack(spacing: 20) {
        ShoeFitPointBox(
            point: ShoeFitPoint(
                id: 1,
                type: .width,
                status: .good
            )
        )
        
        ShoeFitPointBox(
            point: ShoeFitPoint(
                id: 2,
                type: .heel,
                status: .warn
            )
        )
        
        ShoeFitPointBox(
            point: ShoeFitPoint(
                id: 3,
                type: .insole,
                status: .bad
            )
        )
    }
    .padding()
}
