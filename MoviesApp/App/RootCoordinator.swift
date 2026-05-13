//
//  RootCoordinator.swift
//  MoviesApp
//
//  Main shell: `TabView`, lazy tab view models, and per-tab `NavigationStack` paths.

import SwiftUI

struct RootCoordinator: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    @State private var tabViewModels: TabViewModels?

    var body: some View {
        if let tabViewModels {
            tabInterface(viewModels: tabViewModels)
        } else {
            ProgressView("Loading…")
                .task { tabViewModels = TabViewModels(container: container) }
        }
    }

    @ViewBuilder
    private func tabInterface(viewModels: TabViewModels) -> some View {
        TabView(selection: Binding(
            get: { router.selectedTab },
            set: { router.selectedTab = $0 }
        )) {
            Tab("Movies", systemImage: "movieclapper", value: AppTab.movies) {
                NavigationStack(path: moviePathBinding) {
                    FilmsScreen(viewModel: viewModels.catalog)
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }

            Tab("Favorites", systemImage: "heart", value: AppTab.favorites) {
                NavigationStack(path: favoritesPathBinding) {
                    FavoritesScreen()
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }

            Tab("Settings", systemImage: "gear", value: AppTab.settings) {
                SettingsScreen()
            }

            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                NavigationStack(path: searchPathBinding) {
                    SearchScreen(viewModel: viewModels.search)
                        .navigationDestination(for: CatalogRoute.self) { destination(for: $0) }
                }
            }
        }
        .tint(.accentColor)
        .tabBarMinimizeBehavior(.automatic)
        .environment(viewModels.favorites)
        .setAppearanceTheme()
    }

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
