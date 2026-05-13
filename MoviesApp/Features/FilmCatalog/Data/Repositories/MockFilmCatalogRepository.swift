//
//  MockFilmCatalogRepository.swift
//  MoviesApp
//
//  In-memory/async mock catalog for previews, tests, and offline demos.

import Foundation

// Offline bundle-backed catalog for previews, tests, and CI without network flakiness.
struct MockFilmCatalogRepository: FilmCatalogRepository {
    private struct SampleData: Decodable {
        let films: [FilmDTO]
        let people: [PersonDTO]
    }

    private func loadSampleData() throws -> SampleData {
        guard let url = Bundle.main.url(forResource: "SampleData", withExtension: "json") else {
            throw NetworkError.invalidURL
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(SampleData.self, from: data)
        } catch is DecodingError {
            throw NetworkError.decoding
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
    }

    func fetchFilms() async throws -> [Film] {
        try loadSampleData().films.map { $0.toDomain() }
    }

    func fetchFilm(id: String) async throws -> Film {
        let dto = try loadSampleData().films.first { $0.id == id }
        guard let dto else { throw NetworkError.notFound }
        return dto.toDomain()
    }

    func searchFilms(for searchTerm: String) async throws -> [Film] {
        try await fetchFilms().filter { $0.title.localizedStandardContains(searchTerm) }
    }

    func fetchPerson(from urlString: String) async throws -> Person {
        guard let dto = try loadSampleData().people.first else {
            throw NetworkError.invalidResponse
        }
        return dto.toDomain()
    }

    func filmForPreview() throws -> Film {
        guard let dto = try loadSampleData().films.first else {
            throw NetworkError.invalidResponse
        }
        return dto.toDomain()
    }
}
