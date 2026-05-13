//
//  APIEndpoint.swift
//  MoviesApp
//
//  `Sendable` protocol for types that expose a request URL string.

import Foundation

// Any type describing a request can expose a fully-qualified URL string; `Sendable` for async call sites.
protocol APIEndpoint: Sendable {
    // Absolute URL as a string (matches what `HTTPClient.fetch` expects).
    var urlString: String { get }
}
