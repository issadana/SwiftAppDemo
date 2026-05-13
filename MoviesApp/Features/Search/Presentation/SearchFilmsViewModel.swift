//
//  SearchFilmsViewModel.swift
//  MoviesApp
//

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
    }

    // Clears to idle when the query is empty; otherwise loads after a short delay for debouncing.
    func onSearchTextChange() async {
        guard !searchText.isEmpty else {
            state = .idle
            return
        }

        state = .loading

        let term = searchText
        try? await Task.sleep(for: .milliseconds(500))
        guard !Task.isCancelled, searchText == term else { return }

        do {
            let films = try await searchFilmsUseCase.execute(searchTerm: term)
            state = .success(films)
        } catch {
            state = .failure(ErrorMapper.map(error))
        }
    }
}
