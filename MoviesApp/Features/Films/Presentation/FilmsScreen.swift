//
//  FilmsScreen.swift
//  MoviesApp
//

import SwiftUI

// Movies tab root: renders catalog load states and hands success to `FilmListView`.
struct FilmsScreen: View {
    let viewModel: FilmsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                EmptyStateView(
                    systemImage: "movieclapper",
                    title: "Studio Ghibli films",
                    subtitle: "Loading the catalog…"
                )

            case .loading:
                ProgressView {
                    Text("Loading …")
                }

            case .success(let films):
                FilmListView(films: films)

            case .failure(let error):
                ErrorView(error: error) {
                    Task { await viewModel.fetch() }
                }
            }
        }
        .navigationTitle("Movies")
        .task { await viewModel.onAppear() }
        .onDisappear { viewModel.cancelFetch() }
    }
}

#Preview {
    NavigationStack {
        FilmsScreen(viewModel: FilmsViewModel.mock)
    }
    .environment(FavoritesViewModel.mock)
}
