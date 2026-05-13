//
//  FetchPeopleForFilmUseCase.swift
//  MoviesApp
//
//  Loads people linked to a film (director, etc.).

import Foundation

// Resolves each `film.people` URL into a `Person` concurrently.
protocol FetchPeopleForFilmUseCaseProtocol: Sendable {
    func execute(film: Film) async throws -> [Person]
}

// Loads all character URLs on a `Film` concurrently via the catalog repository.
struct FetchPeopleForFilmUseCase: FetchPeopleForFilmUseCaseProtocol {
    private let repository: FilmCatalogRepository

    init(repository: FilmCatalogRepository) {
        self.repository = repository
    }

    func execute(film: Film) async throws -> [Person] {
        try await withThrowingTaskGroup(of: Person.self) { group in
            var loadedPeople: [Person] = []
            for personURL in film.people {
                group.addTask {
                    try await self.repository.fetchPerson(from: personURL)
                }
            }
            for try await person in group {
                loadedPeople.append(person)
            }
            return loadedPeople
        }
    }
}
