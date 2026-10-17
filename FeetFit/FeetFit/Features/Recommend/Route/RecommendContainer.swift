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
    @EnvironmentObject private var tabRouter: TabRouter
    
    var body: some View {
        NavigationStack(path: $path) {
            RecommendListView(
                viewModel: viewModel,
                onShoeTap: { shoe in
                    viewModel.registerShoeClick(shoeId: shoe.id)
                    path.append(.shoeDetail(shoeId: shoe.id))
                },
                onProductTap: { product in
                    path.append(.productDetail(product: product))
                }
            )
            .navigationDestination(for: RecommendRoute.self) { route in
                switch route {
                case .shoeDetail(let shoeId):
                    ShoeDetailView(shoeId: shoeId)
                case .productDetail(let product):
                    ProductDetailView(product: product)
                }
            }
        }
        .onChange(of: tabRouter.selectedTab) { _, newValue in
            guard newValue != .recommend else { return }
            path.removeAll()
        }
    }
}

#Preview {
    RecommendContainer()
        .environmentObject(TabRouter())
}
