//
//  FilmCatalogRepositoryImpl.swift
//  MoviesApp
//
//  `FilmCatalogRepository` backed by `FilmCatalogRemoteDataSource` and DTO mapping.

import Foundation

// Default repository: remote DTOs mapped to domain; search currently filters the full in-memory list.
struct FilmCatalogRepositoryImpl: FilmCatalogRepository {
    private let remote: FilmCatalogRemoteDataSource

    init(remote: FilmCatalogRemoteDataSource) {
        self.remote = remote
        Logger.debug("FilmCatalogRepositoryImpl initialized with remote data source", category: "Repository")
    }

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.remote = GhibliFilmCatalogRemoteDataSource(httpClient: httpClient)
        Logger.debug("FilmCatalogRepositoryImpl initialized with HTTPClient", category: "Repository")
    }

    func fetchFilms() async throws -> [Film] {
        Logger.info("Fetching all films", category: "FilmCatalogRepository")
        do {
            let dtos = try await remote.fetchAllFilms()
            let films = dtos.map { $0.toDomain() }
            Logger.debug("Successfully fetched \(films.count) films", category: "FilmCatalogRepository")
            return films
        } catch {
            Logger.error("Failed to fetch films: \(error.localizedDescription)", category: "FilmCatalogRepository")
            throw error
        }
    }

    func fetchFilm(id: String) async throws -> Film {
        Logger.info("Fetching film with ID: \(id)", category: "FilmCatalogRepository")
        do {
            let film = try await remote.fetchFilm(id: id).toDomain()
            Logger.debug("Successfully fetched film: \(film.title)", category: "FilmCatalogRepository")
            return film
        } catch {
            Logger.error("Failed to fetch film \(id): \(error.localizedDescription)", category: "FilmCatalogRepository")
            throw error
        }
    }

    func searchFilms(for searchTerm: String) async throws -> [Film] {
        Logger.info("Searching films for term: '\(searchTerm)'", category: "FilmCatalogRepository")
        do {
            let results = try await fetchFilms().filter { $0.title.localizedStandardContains(searchTerm) }
            Logger.debug("Search found \(results.count) results for '\(searchTerm)'", category: "FilmCatalogRepository")
            return results
        } catch {
            Logger.error("Search failed for '\(searchTerm)': \(error.localizedDescription)", category: "FilmCatalogRepository")
            throw error
        }
    }

    func fetchPerson(from urlString: String) async throws -> Person {
        Logger.info("Fetching person from URL: \(urlString)", category: "FilmCatalogRepository")
        do {
            let person = try await remote.fetchPerson(from: urlString).toDomain()
            Logger.debug("Successfully fetched person: \(person.name)", category: "FilmCatalogRepository")
            return person
        } catch {
            Logger.error("Failed to fetch person from \(urlString): \(error.localizedDescription)", category: "FilmCatalogRepository")
            throw error
        }
    }
}
