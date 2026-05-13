//
//  FavoritesFeatureFactory.swift
//  MoviesApp
//

import Foundation

/// Builds favorites UI state; depends on catalog APIs to resolve full `Film` models.
@MainActor
struct FavoritesFeatureFactory {
    private let favoritesRepository: FavoritesRepository
    private let filmCatalogRepository: FilmCatalogRepository

    init(favoritesRepository: FavoritesRepository, filmCatalogRepository: FilmCatalogRepository) {
        self.favoritesRepository = favoritesRepository
        self.filmCatalogRepository = filmCatalogRepository
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        let vm = FavoritesViewModel(
            repository: favoritesRepository,
            fetchFilmUseCase: FetchFilmUseCase(repository: filmCatalogRepository),
            fetchFavoriteFilmsUseCase: FetchFavoriteFilmsUseCase(repository: filmCatalogRepository)
        )
        vm.loadIDs()
        return vm
    }
}
