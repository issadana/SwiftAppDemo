//
//  FetchFilmUseCase.swift
//  MoviesApp
//
//  Loads a single film by id.

import Foundation

// Fetches a single film by ID (detail from favorites, or merging a newly favorited row).
protocol FetchFilmUseCaseProtocol: Sendable {
    func execute(id: String) async throws -> Film
}

// Default implementation forwarding to a `FilmCatalogRepository`.
struct FetchFilmUseCase: FetchFilmUseCaseProtocol {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> Film {
        try await repository.fetchFilm(id: id)
    }
}
