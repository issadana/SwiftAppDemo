//
//  AppContainer.swift
//  MoviesApp
//
//  Composition root: wires film catalog and favorites feature factories for the live app and previews.

import Foundation
import Observation

// `@Observable` (Observation macro) — Generates observation hooks so SwiftUI tracks **which properties** you read and refreshes only affected views.
// `@MainActor` — Class methods/properties used while building UI must stay on the main actor (Swift concurrency isolation).
@Observable
@MainActor
final class AppContainer {

    private let filmCatalog: FilmCatalogFeatureFactory
    private let favorites: FavoritesFeatureFactory

    init(
        filmCatalogRepository: FilmCatalogRepository = FilmCatalogRepositoryImpl(httpClient: URLSessionHTTPClient()),
        favoritesRepository: FavoritesRepository = FavoritesRepositoryImpl()
    ) {
        self.filmCatalog = FilmCatalogFeatureFactory(repository: filmCatalogRepository)
        self.favorites = FavoritesFeatureFactory(
            favoritesRepository: favoritesRepository,
            filmCatalogRepository: filmCatalogRepository
        )
    }

    func makeFilmsViewModel() -> FilmsViewModel {
        filmCatalog.makeFilmsViewModel()
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        favorites.makeFavoritesViewModel()
    }

    func makeSearchFilmsViewModel() -> SearchFilmsViewModel {
        filmCatalog.makeSearchFilmsViewModel()
    }

    func makeFilmDetailViewModel(film: Film) -> FilmDetailViewModel {
        filmCatalog.makeFilmDetailViewModel(film: film)
    }

    static func preview(
        filmCatalogRepository: FilmCatalogRepository = MockFilmCatalogRepository(),
        favoritesRepository: FavoritesRepository = MockFavoritesRepository()
    ) -> AppContainer {
        AppContainer(
            filmCatalogRepository: filmCatalogRepository,
            favoritesRepository: favoritesRepository
        )
    }
}
