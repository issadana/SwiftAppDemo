//
//  FilmCatalogRepositoryImpl.swift
//  MoviesApp
//

import Foundation

// Default repository: remote DTOs mapped to domain; search currently filters the full in-memory list.
struct FilmCatalogRepositoryImpl: FilmCatalogRepository {
    private let remote: FilmCatalogRemoteDataSource

    init(remote: FilmCatalogRemoteDataSource) {
        self.remote = remote
    }

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.remote = GhibliFilmCatalogRemoteDataSource(httpClient: httpClient)
    }

    func fetchFilms() async throws -> [Film] {
        let dtos = try await remote.fetchAllFilms()
        return dtos.map { $0.toDomain() }
    }

    func fetchFilm(id: String) async throws -> Film {
        try await remote.fetchFilm(id: id).toDomain()
    }

    func searchFilms(for searchTerm: String) async throws -> [Film] {
        try await fetchFilms().filter { $0.title.localizedStandardContains(searchTerm) }
    }

    func fetchPerson(from urlString: String) async throws -> Person {
        try await remote.fetchPerson(from: urlString).toDomain()
    }
}
