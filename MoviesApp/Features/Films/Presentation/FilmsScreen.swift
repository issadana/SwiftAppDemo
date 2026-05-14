//
//  FilmsScreen.swift
//  MoviesApp
//
//  Films tab: list, loading, and errors.

import SwiftUI

// Movies tab root: renders catalog load states and hands success to `FilmListView`.
struct FilmsScreen: View {
    // `let` — Parent (`RootCoordinator`) creates and owns the VM; this screen doesn’t use `@StateObject`/`@Observable` wrapper because Observation tracks reference reads directly.
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
                    // `Task { }` — unstructured async unit from synchronous retry button tap; awaits VM reload on cooperative pool then hops to UI via `@MainActor` VM.
                    Task { await viewModel.fetch() }
                }
            }
        }
        .navigationTitle("Movies")
        // `.task` — Runs async `onAppear` when the screen appears; cancels if user navigates away mid-fetch.
        .task { await viewModel.onAppear() }
        // `.onDisappear` — Synchronously stops in-flight work so a stale response can’t update UI off-screen.
        .onDisappear { viewModel.cancelFetch() }
    }
}

#Preview {
    NavigationStack {
        FilmsScreen(viewModel: FilmsViewModel.mock)
    }
    .environment(FavoritesViewModel.mock)
}
