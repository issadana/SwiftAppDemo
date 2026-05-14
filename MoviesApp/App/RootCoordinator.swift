//
//  RootCoordinator.swift
//  MoviesApp
//
//  Main shell: `TabView`, lazy tab view models, and per-tab `NavigationStack` paths.

import SwiftUI

struct RootCoordinator: View {
    // Same `@Environment` pattern: factories and navigation objects come from the app root, not initializer arguments.
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    // `@State` — Local coordinator state: once `TabViewModels` exists we keep it for the session (lazy one-time setup).
    @State private var tabViewModels: TabViewModels?

    var body: some View {
        if let tabViewModels {
            tabInterface(viewModels: tabViewModels)
        } else {
            ProgressView("Loading…")
                // `.task` — Structured async work tied to view **lifetime**; cancelled when the view is removed. Runs factory setup once path loads.
                .task { tabViewModels = TabViewModels(container: container) }
        }
    }

    // `@ViewBuilder` — Lets this function contain multiple views / branches (`if`, `switch`) and combine them into one opaque `View` type.
    @ViewBuilder
    private func tabInterface(viewModels: TabViewModels) -> some View {
        // `Binding(get:set:)` — Two-way link: `TabView` reads/writes `router.selectedTab` without owning the router.
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            Tab("Movies", systemImage: "movieclapper", value: AppTab.movies) {
                NavigationStack(path: moviePathBinding) {
                    FilmsScreen(viewModel: viewModels.catalog)
                        // `.navigationDestination(for:)` — Maps pushed `CatalogRoute` values (from `NavigationLink`) into concrete destination views.
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }

            Tab("Favorites", systemImage: "heart", value: AppTab.favorites) {
                NavigationStack(path: favoritesPathBinding) {
                    FavoritesScreen()
                        // `.navigationDestination(for:)` — Same typed detail pushes as Movies tab (`CatalogRoute`).
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }

            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsScreen()
            }

            // `role: .search` — Hints the tab bar this tab is search-centric (system may adjust placement / chrome).
            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                NavigationStack(path: searchPathBinding) {
                    SearchScreen(viewModel: viewModels.search)
                        // `.navigationDestination(for:)` — Detail pushes share one mapper (`destination(for:)`).
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }
        }
        .tint(.accentColor)
        .tabBarMinimizeBehavior(.automatic)
        // `.environment(viewModels.favorites)` — Makes **one** `FavoritesViewModel` visible to every tab’s subtree (`FavoriteButton`, detail toolbar, etc.).
        .environment(viewModels.favorites)
        .setAppearanceTheme()
    }

    // Manual `Binding`s bridge `@Observable` router arrays into `NavigationStack(path:)` (stack pushes mutate `AppRouter` paths).
    private var moviePathBinding: Binding<[CatalogRoute]> {
        Binding(get: { router.moviePath }, set: { router.moviePath = $0 })
    }

    private var favoritesPathBinding: Binding<[CatalogRoute]> {
        Binding(get: { router.favoritesPath }, set: { router.favoritesPath = $0 })
    }

    private var searchPathBinding: Binding<[CatalogRoute]> {
        Binding(get: { router.searchPath }, set: { router.searchPath = $0 })
    }

    /// Catalog feature owns `CatalogRoute`; the app shell maps routes to concrete views (composition root).
    // `@ViewBuilder` — Each `case` can produce a different concrete screen type; builder erases to `some View`.
    @ViewBuilder
    private func destination(for route: CatalogRoute) -> some View {
        switch route {
        case .filmDetail(let film):
            FilmDetailScreen(
                viewModel: container.makeFilmDetailViewModel(film: film)
            )
        }
    }
}

// `@MainActor` — Guarantees UI-facing factories run on the **main thread** (SwiftUI / Observation requirement for models touched from views).
@MainActor
private struct TabViewModels {
    let catalog: FilmsViewModel
    let favorites: FavoritesViewModel
    let search: SearchFilmsViewModel

    init(container: AppContainer) {
        self.catalog = container.makeFilmsViewModel()
        self.favorites = container.makeFavoritesViewModel()
        self.search = container.makeSearchFilmsViewModel()
    }
}

#Preview {
    RootCoordinator()
        .environment(AppContainer.preview())
        .environment(AppRouter())
}
