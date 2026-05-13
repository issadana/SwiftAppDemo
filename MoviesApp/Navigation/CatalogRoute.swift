//
//  CatalogRoute.swift
//  MoviesApp
//

import Foundation

// Navigation destinations owned by the FilmCatalog feature; used in per-tab NavigationStack paths.
enum CatalogRoute: Hashable {
    case filmDetail(Film)
}
