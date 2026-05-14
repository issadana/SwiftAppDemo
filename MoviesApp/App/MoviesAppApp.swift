//
//  MoviesAppApp.swift
//  MoviesApp
//
//  SwiftUI app entry (`@main`): creates AppContainer + AppRouter, surfaces RootView, injects dependencies via `.environment`.

import SwiftUI

// MARK: - Attribute cheatsheet (this file)
// `@main` — Marks the **program entry point**. The runtime starts here (like a `main()` function); exactly one `@main` type per executable target.
// `App` — SwiftUI’s application protocol: you describe **scenes** (windows) instead of manually creating `UIApplication`.
@main
struct MoviesAppApp: App {
    // `@State` — SwiftUI stores this property’s backing storage outside the struct and keeps **stable identity** across `body` recomputations.
    //           Needed here because `App` is a struct but we hold **reference types** (`AppContainer`, `AppRouter`) that must not be recreated every refresh.
    @State private var container = AppContainer()
    @State private var router = AppRouter()

    var body: some Scene {
        // `WindowGroup` — Declares one or more windows for this app on iOS/macOS; system manages lifecycle.
        WindowGroup {
            RootView()
                // `.environment(_)` — Puts objects into SwiftUI’s **environment** so any descendant can read them with `@Environment(Type.self)`.
                .environment(container)
                .environment(router)
        }
    }
}
