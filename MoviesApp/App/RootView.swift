//
//  RootView.swift
//  MoviesApp
//
//  Root view after `WindowGroup`; switches on `RootDestination` (today only `.main`).

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        switch router.rootDestination {
        case .main:
            RootCoordinator()
        }
    }
}

#Preview {
    RootView()
        .environment(AppContainer.preview())
        .environment(AppRouter())
}
