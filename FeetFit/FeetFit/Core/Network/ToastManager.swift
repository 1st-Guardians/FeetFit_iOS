//
//  ToastManager.swift
//  FeetFit
//
//  Created by 이채은 on 5/29/26.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published private(set) var isPresented: Bool = false
    @Published private(set) var message: String = ""
    
    private var hideTask: Task<Void, Never>?
    
    func show(_ message: String) {
        hideTask?.cancel()
        self.message = message
        withAnimation { self.isPresented = true }
        
        hideTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
            await MainActor.run {
                withAnimation { self?.isPresented = false }
            }
        }
    }
    
    func hide() {
        hideTask?.cancel()
        withAnimation { isPresented = false }
    }
}
