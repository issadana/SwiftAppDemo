//
//  FilmListView.swift
//  MoviesApp
//
//  Reusable SwiftUI list of `Film` rows with navigation.

import SwiftUI

// Reusable list: each row navigates by appending `Route.filmDetail` to the enclosing stack.
struct FilmListView: View {
    var films: [Film]

    var body: some View {
        List(films) { film in
            NavigationLink(value: CatalogRoute.filmDetail(film)) {
                FilmRow(film: film)
            }
        }
    }
}

private struct FilmRow: View {
    let film: Film

    var body: some View {
        HStack(alignment: .top) {
            FilmImageView(urlPath: film.image)
                .frame(width: 100, height: 150)

            VStack(alignment: .leading) {
                HStack {
                    Text(film.title)
                        .bold()

                    Spacer()
                    FavoriteButton(filmID: film.id)
                        .buttonStyle(.plain)
                        .controlSize(.large)
                }
                .padding(.bottom, 5)

                Text("Directed by \(film.director)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Released: \(film.releaseYear)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        FilmListView(films: Film.mocks)
    }
    .environment(container.makeFavoritesViewModel())
}
