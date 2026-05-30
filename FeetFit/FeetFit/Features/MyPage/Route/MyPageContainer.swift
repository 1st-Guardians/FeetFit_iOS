//
//  MyPageContainer.swift
//  FeetFit
//
//  Created by 이채은 on 5/30/26.
//

import SwiftUI

struct MyPageContainer: View {
    @State private var path: [MyPageRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            MyPageView(
                onProfileEditTap: {
                    path.append(.profileEditing)
                },
                onHardwarePairingTap: {
                    path.append(.hardwarePairing)
                }
            )
            .navigationDestination(for: MyPageRoute.self) { route in
                switch route {
                case .mypage:
                    MyPageView(
                        onProfileEditTap: {
                            path.append(.profileEditing)
                        },
                        onHardwarePairingTap: {
                            path.append(.hardwarePairing)
                        }
                    )
                    
                case .profileEditing:
                    ProfileEditView()
                    
                case .hardwarePairing:
                    HardwarePairingView {
                        path.removeLast()
                    }
                }
            }
        }
    }
}
