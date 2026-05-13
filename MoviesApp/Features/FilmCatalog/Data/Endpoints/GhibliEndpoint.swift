//
//  GhibliEndpoint.swift
//  MoviesApp
//

import Foundation

// Typed URLs for the subset of the Ghibli HTTP API this app calls.
enum GhibliEndpoint: APIEndpoint {
    case films
    case film(id: String)
    case person(absoluteURL: String)

    var urlString: String {
        switch self {
        case .films:
            // List endpoint: `/films`.
            return AppConstants.API.filmsURL
        case .film(let id):
            // Single resource: `/films/{id}`.
            return "\(AppConstants.API.filmsURL)/\(id)"
        case .person(let absoluteURL):
            // API returns full person URLs on each film; use them verbatim.
            return absoluteURL
        }
    }
}
