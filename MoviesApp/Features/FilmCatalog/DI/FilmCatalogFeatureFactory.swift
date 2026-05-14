//
//  FilmCatalogFeatureFactory.swift
//  MoviesApp
//
//  Builds catalog-related view models from a `FilmCatalogRepository`.

import Foundation

// Builds all ViewModels for the FilmCatalog feature; owns the repository reference.
// `@MainActor` — Factories construct `@MainActor` ViewModels; marking the struct keeps calls aligned with UI isolation.
@MainActor
struct FilmCatalogFeatureFactory {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func makeFilmsViewModel() -> FilmsViewModel {
        FilmsViewModel(fetchFilmsUseCase: FetchFilmsUseCase(repository: repository))
    }

    func makeSearchFilmsViewModel() -> SearchFilmsViewModel {
        SearchFilmsViewModel(searchFilmsUseCase: SearchFilmsUseCase(repository: repository))
    }

    func makeFilmDetailViewModel(film: Film) -> FilmDetailViewModel {
        FilmDetailViewModel(
            film: film,
            fetchPeopleUseCase: FetchPeopleForFilmUseCase(repository: repository)
        )
    }
}
