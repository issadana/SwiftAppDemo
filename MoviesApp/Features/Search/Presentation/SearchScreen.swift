//
//  SearchScreen.swift
//  MoviesApp
//
//  Search tab with debounced query and results.

import SwiftUI

// Search tab: `Searchable` field + results list sharing `FilmListView` with other tabs.
struct SearchScreen: View {
    // Passed from coordinator — same Observation pattern as `FilmsScreen`.
    let viewModel: SearchFilmsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                EmptyStateView(
                    systemImage: "magnifyingglass",
                    title: "Search films",
                    subtitle: "Your search results will appear here."
                )
            case .loading:
                ProgressView()
            case .failure(let error):
                ErrorView(error: error) {
                    // `Task { }` — Retry button is synchronous; spin another debounced search pass through the VM.
                    Task { await viewModel.onSearchTextChange() }
                }
            case .success(let films):
                FilmListView(films: films)
            }
        }
        .navigationTitle("Search Movies")
        // `Bindable` — Wraps an `@Observable` object so SwiftUI controls (`searchable`) get a real `Binding` to `searchText`.
        .searchable(text: Bindable(viewModel).searchText)
        // `.task(id:)` — Restarts async work whenever `searchText` changes (implements debounce inside the VM); cancelled when id changes or view disappears.
        .task(id: viewModel.searchText) {
            await viewModel.onSearchTextChange()
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        SearchScreen(viewModel: container.makeSearchFilmsViewModel())
    }
    .environment(container.makeFavoritesViewModel())
}
