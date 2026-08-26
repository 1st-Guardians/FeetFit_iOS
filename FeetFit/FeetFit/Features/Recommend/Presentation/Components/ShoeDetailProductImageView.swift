//
//  ShoeDetailProductImageView.swift
//  FeetFit
//

import SwiftUI

struct ShoeDetailProductImageView: View {
    let urlString: String

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(height: 320)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 320)
                    .clipped()

            case .failure:
                Image(systemName: "shoeprints.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.gray01)
                    .frame(height: 320)

            @unknown default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    ShoeDetailProductImageView(urlString: "https://picsum.photos/seed/feetfit-shoe/800/800")
}
