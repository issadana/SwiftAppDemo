//
//  MoviesAppApp.swift
//  MoviesApp
//
//  SwiftUI `@main` entry: window scene, dependency container, and shared router on the environment.

import SwiftUI

@main
struct MoviesAppApp: App {
    @State private var container = AppContainer()
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(router)
        }
    }
}
