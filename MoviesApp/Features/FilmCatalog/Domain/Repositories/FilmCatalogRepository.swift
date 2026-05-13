//
//  FilmCatalogRepository.swift
//  MoviesApp
//

import Foundation

// Catalog boundary: films list, single film, people by URL, and client-side title search.
protocol FilmCatalogRepository: Sendable {
    // Full list for browse and for local title filtering in search.
    func fetchFilms() async throws -> [Film]
    // Single film by API id (favorites hydrate, detail fallbacks).
    func fetchFilm(id: String) async throws -> Film
    // Follows absolute person URLs embedded in a film payload.
    func fetchPerson(from urlString: String) async throws -> Person
    // Repository decides how to match titles against `searchTerm`.
    func searchFilms(for searchTerm: String) async throws -> [Film]
}
