//
//  SearchScreen.swift
//  MoviesApp
//
//  Search tab with debounced query and results.

import SwiftUI

// Search tab: `Searchable` field + results list sharing `FilmListView` with other tabs.
struct SearchScreen: View {
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
                    Task { await viewModel.onSearchTextChange() }
                }
            case .success(let films):
                FilmListView(films: films)
            }
        }
        .navigationTitle("Search Movies")
        .searchable(text: Bindable(viewModel).searchText)
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
