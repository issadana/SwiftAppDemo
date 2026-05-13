//
//  FetchFilmsUseCase.swift
//  MoviesApp
//
//  Loads the full film list from the repository.

import Foundation

// Application service wrapping `FilmCatalogRepository.fetchFilms()` for the films list screen.
protocol FetchFilmsUseCaseProtocol: Sendable {
    func execute() async throws -> [Film]
}

// Default implementation forwarding to a `FilmCatalogRepository`.
struct FetchFilmsUseCase: FetchFilmsUseCaseProtocol {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Film] {
        try await repository.fetchFilms()
    }
}
