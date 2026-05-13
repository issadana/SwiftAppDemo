//
//  AppConstants.swift
//  MoviesApp
//

import Foundation

// Central place for magic strings and numbers used across modules.
enum AppConstants {
    // Network base URL and derived paths for the Studio Ghibli HTTP API.
    enum API {
        static let baseURL = "https://ghibliapi.vercel.app"
        static let filmsURL = "\(baseURL)/films"
        static let timeoutSeconds: TimeInterval = 30
    }

    // `UserDefaults` keys and related storage identifiers.
    enum Storage {
        static let favoriteFilms = "MoviesApp.FavoriteFilms"
    }
}
