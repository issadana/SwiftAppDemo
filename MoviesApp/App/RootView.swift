//
//  RootView.swift
//  MoviesApp
//

import SwiftUI

// First real screen after `WindowGroup`; will branch on `rootDestination` when onboarding exists.
struct RootView: View {
    // Reads the router placed on the environment by `MoviesAppApp`.
    @Environment(AppRouter.self) private var router

    var body: some View {
        // Today only `.main` exists; add cases here for splash, login, etc.
        switch router.rootDestination {
        case .main:
            // Tab bar + stacks live here.
            RootCoordinator()
        }
    }
}

#Preview {
    RootView()
        .environment(AppContainer.preview())
        .environment(AppRouter())
}
