//
//  ShoeListView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeListView: View {
    let shoes: [ShoeInfo]
    var onShoeTap: (ShoeInfo) -> Void = { _ in }
    var onShoeAppear: (ShoeInfo) -> Void = { _ in }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(shoes.indices, id: \.self) { index in
                Button {
                    onShoeTap(shoes[index])
                } label: {
                     ShoeInfoView(shoe: shoes[index])
                }
                .buttonStyle(.plain)
                .onAppear {
                    onShoeAppear(shoes[index])
                }
                
                if index != shoes.indices.last {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    ShoeListView(shoes: [])
}
