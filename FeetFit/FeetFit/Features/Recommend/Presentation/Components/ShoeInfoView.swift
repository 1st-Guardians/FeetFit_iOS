//
//  ShoeInfoView.swift
//  FeetFit
//
//  Created by 이채은 on 5/26/26.
//

import SwiftUI

struct ShoeInfoView: View {
    let shoe: ShoeInfo
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Rectangle()
                    .fill(.white)
                    .frame(width: 78, height: 78)
                    .mainBoxStyle()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(shoe.brand)
                        .pretendardFont(.Caption)
                    
                    Text(shoe.name)
                        .pretendardFont(.BlockText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(shoe.formattedPrice)
                        .pretendardFont(.Caption)
                    
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 15.75))
                            .foregroundStyle(.yellow01)
                        
                        Text(shoe.formattedRating)
                            .pretendardFont(.Caption)
                            .foregroundStyle(.yellow01)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Divider()
                .padding(.vertical, 12)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ShoeInfoView(
        shoe: ShoeInfo(
            id: 1,
            brand: "Converse",
            name: "척테일러 올스타 클래식 블랙 어쩌구 저쩌구신발이레용",
            price: 75000,
            rating: 4.3,
            fitScore: 92,
            interestCount: 128,
            imageURL: ""
        )
    )
}
