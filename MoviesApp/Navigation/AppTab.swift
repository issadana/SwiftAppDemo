//
//  AppTab.swift
//  MoviesApp
//
//  Tab identifiers for the app shell (not feature-owned).
//

import Foundation

enum AppTab: String, Hashable, CaseIterable, Identifiable {
    case movies
    case favorites
    case settings
    case search

    var id: String { rawValue }
}
