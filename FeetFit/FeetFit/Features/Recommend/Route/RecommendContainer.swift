//
//  RecommendContainer.swift
//  FeetFit
//
//  Created by 이채은 on 6/28/26.
//

import SwiftUI

struct RecommendContainer: View {
    @State private var path: [RecommendRoute] = []
    @StateObject private var viewModel = RecommendListViewModel()
    
    var body: some View {
        NavigationStack(path: $path) {
            RecommendListView(
                viewModel: viewModel,
                onShoeTap: { shoe in
                    viewModel.registerShoeClick(shoeId: shoe.id)
                    path.append(.shoeDetail(shoeId: shoe.id))
                }
            )
            .navigationDestination(for: RecommendRoute.self) { route in
                switch route {
                case .shoeDetail(let shoeId):
                    ShoeDetailView(shoeId: shoeId)
                }
            }
        }
    }
}

#Preview {
    RecommendContainer()
}
