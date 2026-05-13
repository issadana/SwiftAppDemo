//
//  UserDefaultsFavoritesRepository.swift
//  MoviesApp
//
//  `FavoritesRepository` storing favorite ids in `UserDefaults`.

import Foundation

// Production `FavoritesRepository`: stores a de-duplicated list of film IDs as a string array.
struct FavoritesRepositoryImpl: FavoritesRepository {
    func load() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: AppConstants.Storage.favoriteFilms) ?? []
        return Set(array)
    }

    func save(favoriteIDs: Set<String>) {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: AppConstants.Storage.favoriteFilms)
    }
}
