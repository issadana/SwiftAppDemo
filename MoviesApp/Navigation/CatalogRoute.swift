//
//  CatalogRoute.swift
//  MoviesApp
//
//  Film catalog navigation destinations (e.g. film detail) for stack paths.

import Foundation

// Navigation destinations owned by the FilmCatalog feature; used in per-tab NavigationStack paths.
enum CatalogRoute: Hashable {
    case filmDetail(Film)
}
