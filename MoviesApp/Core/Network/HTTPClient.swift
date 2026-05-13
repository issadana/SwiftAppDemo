//
//  HTTPClient.swift
//  MoviesApp
//
//  Abstraction for async JSON GET + decode (testable vs `URLSession`).

import Foundation

// Thin abstraction over `URLSession` so tests can stub JSON without hitting the network.
protocol HTTPClient: Sendable {
    // GETs `urlString`, decodes JSON into `T`, and maps failures to typed throws from the implementation.
    func fetch<T: Decodable>(_ urlString: String, as type: T.Type) async throws -> T
}
