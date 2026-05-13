//
//  FilmCatalogRemoteDataSource.swift
//  MoviesApp
//

import Foundation

// Narrow gateway: decode DTOs only; mapping to `Film`/`Person` stays in the repository layer.
protocol FilmCatalogRemoteDataSource: Sendable {
    // Decodes the full catalog array from the films list endpoint.
    func fetchAllFilms() async throws -> [FilmDTO]
    // Decodes one film document for favorites and detail refreshes.
    func fetchFilm(id: String) async throws -> FilmDTO
    // Decodes a person given the href stored on a `FilmDTO.people` entry.
    func fetchPerson(from urlString: String) async throws -> PersonDTO
}

// Live implementation backed by `HTTPClient` + `GhibliEndpoint`.
struct GhibliFilmCatalogRemoteDataSource: FilmCatalogRemoteDataSource {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchAllFilms() async throws -> [FilmDTO] {
        try await httpClient.fetch(GhibliEndpoint.films.urlString, as: [FilmDTO].self)
    }

    func fetchFilm(id: String) async throws -> FilmDTO {
        try await httpClient.fetch(GhibliEndpoint.film(id: id).urlString, as: FilmDTO.self)
    }

    func fetchPerson(from urlString: String) async throws -> PersonDTO {
        try await httpClient.fetch(GhibliEndpoint.person(absoluteURL: urlString).urlString, as: PersonDTO.self)
    }
}
