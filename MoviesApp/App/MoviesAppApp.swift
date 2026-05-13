//
//  MoviesAppApp.swift
//  MoviesApp
//

// SwiftUI app entry (`App`, `Scene`, `WindowGroup`).
import SwiftUI

// Declares the executable target and the scene graph’s root.
@main
struct MoviesAppApp: App {
    // Global service locator wired into the view tree via `.environment`.
    @State private var container = AppContainer()
    // Shared navigation state (tabs, paths) also injected with `.environment`.
    @State private var router = AppRouter()

    // Describes the windows this app owns (here: one primary window).
    var body: some Scene {
        WindowGroup {
            // Root view chooses coordinator vs future splash/auth once `RootDestination` grows.
            RootView()
                // Makes `AppContainer` visible to descendants (`@Environment(AppContainer.self)`).
                .environment(container)
                // Makes `AppRouter` visible for navigation bindings.
                .environment(router)
        }
    }
}
