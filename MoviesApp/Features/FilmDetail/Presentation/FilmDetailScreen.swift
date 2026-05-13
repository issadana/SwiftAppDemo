//
//  FilmDetailScreen.swift
//  MoviesApp
//

import SwiftUI

// Push destination for `Route.filmDetail`: banner, metadata grid, description, characters.
struct FilmDetailScreen: View {
    let viewModel: FilmDetailViewModel
    @Environment(FavoritesViewModel.self) private var favoritesViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 7) {
                FilmImageView(urlPath: viewModel.film.bannerImage)
                    .frame(height: 300)
                    .containerRelativeFrame(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.film.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Grid(alignment: .leading) {
                        InfoRow(label: "Director", value: viewModel.film.director)
                        InfoRow(label: "Producer", value: viewModel.film.producer)
                        InfoRow(label: "Release Date", value: viewModel.film.releaseYear)
                        InfoRow(label: "Running Time", value: "\(viewModel.film.duration) minutes")
                        InfoRow(label: "Score", value: "\(viewModel.film.score)/100")
                    }
                    .padding(.vertical, 8)

                    Divider()

                    Text("Description")
                        .font(.headline)

                    Text(viewModel.film.description)

                    Divider()

                    CharacterSectionView(viewModel: viewModel)
                }
                .padding()
            }
        }
        .toolbar {
            FavoriteButton(filmID: viewModel.film.id)
        }
        .task(id: viewModel.film.id) { await viewModel.onAppear() }
        .onDisappear { viewModel.cancelFetch() }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        GridRow {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.subheadline)
        }
    }
}

private struct CharacterSectionView: View {
    let viewModel: FilmDetailViewModel

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Text("Characters")
                    .font(.headline)

                switch viewModel.state {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()

                case .success(let people):
                    ForEach(people) { person in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(person.name)

                            HStack(spacing: 8) {
                                Label(person.gender, systemImage: "person.fill")
                                Text("Age: \(person.age)")
                                Spacer()
                                Label(person.eyeColor, systemImage: "eye")
                                Text("Hair: \(person.hairColor)")
                            }
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .lineLimit(1)
                        }
                    }

                case .failure(let error):
                    Text(error.errorDescription ?? "Unknown error")
                        .foregroundStyle(.pink)
                }
            }
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    NavigationStack {
        FilmDetailScreen(
            viewModel: container.makeFilmDetailViewModel(film: Film.mock)
        )
    }
    .environment(container.makeFavoritesViewModel())
}
