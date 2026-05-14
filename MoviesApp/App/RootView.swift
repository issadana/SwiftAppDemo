//
//  RootView.swift
//  MoviesApp
//
//  Root view after `WindowGroup`; switches on `RootDestination` (today only `.main`).

import SwiftUI

struct RootView: View {
    // `@Environment(Type.self)` — Pulls a value **injected higher up** (here: `MoviesAppApp` via `.environment(router)`).
    // With Observation, pass `.self`; SwiftUI subscribes to `@Observable` routers and refreshes this view when navigation changes.
    @Environment(AppRouter.self) private var router

    var body: some View {
        switch router.rootDestination {
        case .main:
            RootCoordinator()
        }
    }
}

// `#Preview { }` — Xcode preview macro: builds a tiny sandbox UI; must repeat `.environment(...)` calls the real app uses.
#Preview {
    RootView()
        .environment(AppContainer.preview())
        .environment(AppRouter())
}
