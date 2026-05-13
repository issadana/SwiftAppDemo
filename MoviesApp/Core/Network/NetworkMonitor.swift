//
//  NetworkMonitor.swift
//  MoviesApp
//

import Foundation
import Network
import Observation

// Real-time network connectivity observer using NWPathMonitor.
// @Observable — views automatically react when connectivity changes.
// @MainActor — all state mutations happen on the main thread.
// Injected into AppContainer as a singleton.

@Observable
@MainActor
final class NetworkMonitor {
    private(set) var isConnected: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.ghibliapp.network-monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
