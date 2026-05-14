//
//  AppRouter.swift
//  MoviesApp
//
//  Observable app navigation: selected tab and `NavigationStack` paths per tab.

import Foundation
import Observation

// `@Observable` — Changing `selectedTab` or any `...Path` array notifies SwiftUI readers (e.g. `TabView`, `NavigationStack` bindings).
// `@MainActor` — Navigation state is manipulated alongside UI; keeps mutations thread-safe with SwiftUI.
@Observable
@MainActor
final class AppRouter {
    var rootDestination: RootDestination = .main

    var selectedTab: AppTab = .movies

    var moviePath: [CatalogRoute] = []
    var favoritesPath: [CatalogRoute] = []
    var searchPath: [CatalogRoute] = []

    func navigate(to route: CatalogRoute, in tab: AppTab) {
        switch tab {
        case .movies: moviePath.append(route)
        case .favorites: favoritesPath.append(route)
        case .search: searchPath.append(route)
        case .settings: break
        }
    }

    func pop(in tab: AppTab) {
        switch tab {
        case .movies: if !moviePath.isEmpty { moviePath.removeLast() }
        case .favorites: if !favoritesPath.isEmpty { favoritesPath.removeLast() }
        case .search: if !searchPath.isEmpty { searchPath.removeLast() }
        case .settings: break
        }
    }

    func popToRoot(in tab: AppTab) {
        switch tab {
        case .movies: moviePath.removeAll()
        case .favorites: favoritesPath.removeAll()
        case .search: searchPath.removeAll()
        case .settings: break
        }
    }

    func clearSearchNavigation() {
        searchPath.removeAll()
    }
}
