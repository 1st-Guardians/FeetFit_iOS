//
//  HomeContainer.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import SwiftUI

struct HomeContainer: View {
    @State private var router = NavigationRouter<HomeRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .main:
                        HomeView()
                    case .measurement:
                        FootMeasurementConnectingView()
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
                .navigationDestination(for: MeasurementRoute.self) { route in
                    switch route {
                    case .connecting:
                        FootMeasurementConnectingView()
                            .toolbar(.hidden, for: .tabBar)
                    case .start:
                        FootMeasurementStartView()
                            .toolbar(.hidden, for: .tabBar)
                    case .progress:
                        FootMeasurementProgressView()
                            .toolbar(.hidden, for: .tabBar)
                    case .exporting:
                        FootMeasurementDataExportingView()
                            .toolbar(.hidden, for: .tabBar)
                    case .finish:
                        FootMeasurementFinishView()
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    HomeContainer()
}
