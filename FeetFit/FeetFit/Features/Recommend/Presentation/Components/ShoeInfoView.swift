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
        HStack(spacing: 20) {
            shoeImage
            
            VStack(alignment: .leading, spacing: 2) {
                Text(shoe.brand)
                    .pretendardFont(.Caption)
                
                Text(shoe.name)
                    .pretendardFont(.BlockText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var shoeImage: some View {
        Group {
            if let url = URL(string: shoe.imageURL), !shoe.imageURL.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Rectangle()
                    .fill(.white)
                    .overlay {
                        Image(systemName: "shoe.2")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray02)
                    }
            }
        }
        .frame(width: 78, height: 78)
        .mainBoxStyle()
    }
}

