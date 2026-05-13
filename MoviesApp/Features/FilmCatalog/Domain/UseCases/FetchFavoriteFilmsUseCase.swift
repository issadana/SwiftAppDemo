//
//  FetchFavoriteFilmsUseCase.swift
//  MoviesApp
//
//  Resolves favorite films from a set of ids.

import Foundation

// Resolves many bookmarked film IDs to full `Film` values in parallel; used by the Favorites tab.
protocol FetchFavoriteFilmsUseCaseProtocol: Sendable {
    func execute(favoriteIDs: Set<String>) async throws -> [Film]
}

// One network request per favorite ID in parallel, then stable sort by localized title.
struct FetchFavoriteFilmsUseCase: FetchFavoriteFilmsUseCaseProtocol {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func execute(favoriteIDs: Set<String>) async throws -> [Film] {
        guard !favoriteIDs.isEmpty else { return [] }

        return try await withThrowingTaskGroup(of: Film.self) { group in
            for id in favoriteIDs {
                group.addTask {
                    try await repository.fetchFilm(id: id)
                }
            }
            var films: [Film] = []
            for try await film in group {
                films.append(film)
            }
            return films.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        }
    }
}
