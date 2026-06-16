//
//  HomeContainer.swift
//  FeetFit
//
//  Created by 김미주 on 5/31/26.
//

import SwiftUI

struct HomeContainer: View {
    @State private var router = NavigationRouter<HomeRoute>()
    @State private var measurementViewModel = FootMeasurementViewModel()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .main:
                        HomeView()

                    case .measurement:
                        FootMeasurementConnectingView(
                            viewModel: measurementViewModel
                        )
                        .toolbar(.hidden, for: .tabBar)

                    case .measurementStart:
                        FootMeasurementStartView()
                            .toolbar(.hidden, for: .tabBar)

                    case .measurementProgress:
                        FootMeasurementProgressView(
                            viewModel: measurementViewModel
                        )
                        .toolbar(.hidden, for: .tabBar)

                    case .measurementExporting:
                        FootMeasurementDataExportingView()
                            .toolbar(.hidden, for: .tabBar)

                    case .measurementFinish:
                        FootMeasurementFinishView()
                            .toolbar(.hidden, for: .tabBar)

                    case .report(let date):
                        ResultView(selectedDate: date)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
        }
        .environment(router)
    }
}
