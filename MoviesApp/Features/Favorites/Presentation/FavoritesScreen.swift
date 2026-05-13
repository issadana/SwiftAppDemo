//
//  FavoritesScreen.swift
//  MoviesApp
//
//  Favorites tab: list of favorite films.

import SwiftUI

// Favorites tab: reads `FavoritesViewModel` from the environment (set in `RootCoordinator`).
struct FavoritesScreen: View {
    @Environment(FavoritesViewModel.self) private var viewModel

    var body: some View {
        Group {
            switch viewModel.filmsState {
            case .idle, .loading:
                ProgressView("Loading…")

            case .success(let films):
                if films.isEmpty {
                    EmptyStateView(
                        systemImage: "heart",
                        title: "No favorites yet",
                        subtitle: "Heart a film from the Movies tab to see it here."
                    )
                } else {
                    FilmListView(films: films)
                }

            case .failure(let error):
                ErrorView(error: error) {
                    Task { await viewModel.refreshFilms() }
                }
            }
        }
        .navigationTitle("Favorites")
        .task { await viewModel.refreshFilms() }
        .onDisappear { viewModel.cancelRefresh() }
    }
}

#Preview {
    NavigationStack {
        FavoritesScreen()
    }
    .environment(FavoritesViewModel.mock)
}
