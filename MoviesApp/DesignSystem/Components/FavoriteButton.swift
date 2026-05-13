//
//  FavoriteButton.swift
//  MoviesApp
//

import SwiftUI

// Toolbar or row control: toggles membership in `FavoritesViewModel.favoriteIDs`.
struct FavoriteButton: View {
    let filmID: String
    @Environment(FavoritesViewModel.self) private var favoritesViewModel

    var isFavorite: Bool {
        favoritesViewModel.isFavorite(filmID: filmID)
    }

    var body: some View {
        Button {
            favoritesViewModel.toggleFavorite(filmID: filmID)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? Color.pink : Color.gray)
        }
    }
}
