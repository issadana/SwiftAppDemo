//
//  FavoritesRepository.swift
//  MoviesApp
//

import Foundation

// Persists favorited film IDs (e.g. `UserDefaults`) behind a small, mock-friendly API.
protocol FavoritesRepository: Sendable {
    // Returns the current bookmarked film ids (empty when never saved).
    func load() -> Set<String>
    // Overwrites storage with the latest set (callers dedupe via `Set`).
    func save(favoriteIDs: Set<String>)
}
