//
//  ShoeListView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeListView: View {
    let shoes: [ShoeInfo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(shoes.indices, id: \.self) { index in
                ShoeInfoView(shoe: shoes[index])
                
                if index != shoes.indices.last {
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    ShoeListView(shoes: ShoeRecommendation.mock.shoes)
}
