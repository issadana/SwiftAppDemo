//
//  SearchFilmsViewModel.swift
//  MoviesApp
//
//  Debounced search over `SearchFilmsUseCase`.

import Foundation
import Observation

// Debounced search over the catalog (client-side filter via repository in current implementation).
@Observable
@MainActor
final class SearchFilmsViewModel {
    // Bound from `.searchable`; changes retrigger `.task(id:)` in `SearchScreen`.
    var searchText: String = ""
    private(set) var state: ViewState<[Film]> = .idle

    private let searchFilmsUseCase: SearchFilmsUseCaseProtocol

    init(searchFilmsUseCase: SearchFilmsUseCaseProtocol) {
        self.searchFilmsUseCase = searchFilmsUseCase
        Logger.debug("SearchFilmsViewModel initialized", category: "SearchFilmsViewModel")
    }

    // Clears to idle when the query is empty; otherwise loads after a short delay for debouncing.
    func onSearchTextChange() async {
        Logger.debug("Search text changed to: '\(searchText)'", category: "SearchFilmsViewModel")
        
        guard !searchText.isEmpty else {
            Logger.debug("Search text is empty, resetting to idle", category: "SearchFilmsViewModel")
            state = .idle
            return
        }

        state = .loading
        Logger.info("Starting search for: '\(searchText)'", category: "SearchFilmsViewModel")

        let term = searchText
        Logger.debug("Debouncing search request for 500ms", category: "SearchFilmsViewModel")
        try? await Task.sleep(for: .milliseconds(500))
        
        guard !Task.isCancelled, searchText == term else {
            Logger.debug("Search task was cancelled or search term changed", category: "SearchFilmsViewModel")
            return
        }

        do {
            Logger.debug("Executing search for: '\(term)'", category: "SearchFilmsViewModel")
            let films = try await searchFilmsUseCase.execute(searchTerm: term)
            state = .success(films)
            Logger.info(
                "Search completed: found \(films.count) films for '\(term)'",
                category: "SearchFilmsViewModel"
            )
        } catch {
            let appError = ErrorMapper.map(error)
            state = .failure(appError)
            Logger.error(
                "Search failed for '\(term)': \(error.localizedDescription)",
                category: "SearchFilmsViewModel"
            )
        }
    }
}
