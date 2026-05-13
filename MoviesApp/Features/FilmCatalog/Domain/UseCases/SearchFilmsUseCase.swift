//
//  SearchFilmsUseCase.swift
//  MoviesApp
//

import Foundation

// Delegates title filtering to the repository implementation (currently client-side substring match).
protocol SearchFilmsUseCaseProtocol: Sendable {
    func execute(searchTerm: String) async throws -> [Film]
}

// Default implementation forwarding to a `FilmCatalogRepository`.
struct SearchFilmsUseCase: SearchFilmsUseCaseProtocol {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func execute(searchTerm: String) async throws -> [Film] {
        try await repository.searchFilms(for: searchTerm)
    }
}
