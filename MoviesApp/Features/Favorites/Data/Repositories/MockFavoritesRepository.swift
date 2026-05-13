//
//  MockFavoritesRepository.swift
//  MoviesApp
//

import Foundation

// In-memory favorites stub: one fixed ID for previews; `save` is a no-op.
struct MockFavoritesRepository: FavoritesRepository {
    func load() -> Set<String> {
        ["2baf70d1-42bb-4437-b551-e5fed5a87abe"]
    }

    func save(favoriteIDs: Set<String>) {}
}
