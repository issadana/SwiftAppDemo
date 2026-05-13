//
//  FavoritesViewModel.swift
//  MoviesApp
//

import Foundation
import Observation

// Drives favorites list, persistence, and heart-button state via `@Environment` injection.
@Observable
@MainActor
final class FavoritesViewModel {
    // Set of film IDs saved locally; toggles update this and `UserDefaults`.
    private(set) var favoriteIDs: Set<String> = []
    // Full `Film` rows for the Favorites tab (rebuilt when IDs or network results change).
    private(set) var filmsState: ViewState<[Film]> = .idle

    private let repository: FavoritesRepository
    private let fetchFilmUseCase: FetchFilmUseCaseProtocol
    private let fetchFavoriteFilmsUseCase: FetchFavoriteFilmsUseCaseProtocol
    private var refreshTask: Task<Void, Never>?

    init(
        repository: FavoritesRepository,
        fetchFilmUseCase: FetchFilmUseCaseProtocol,
        fetchFavoriteFilmsUseCase: FetchFavoriteFilmsUseCaseProtocol
    ) {
        self.repository = repository
        self.fetchFilmUseCase = fetchFilmUseCase
        self.fetchFavoriteFilmsUseCase = fetchFavoriteFilmsUseCase
    }

    // Loads IDs from disk (or mock) without fetching full `Film` models.
    func loadIDs() {
        favoriteIDs = repository.load()
    }

    // Fetches catalog entries for every stored ID in parallel; shows loading and errors inline.
    func refreshFilms() async {
        refreshTask?.cancel()
        loadIDs()

        guard !favoriteIDs.isEmpty else {
            filmsState = .success([])
            return
        }

        refreshTask = Task {
            filmsState = .loading
            do {
                let films = try await fetchFavoriteFilmsUseCase.execute(favoriteIDs: favoriteIDs)
                guard !Task.isCancelled else { return }
                filmsState = .success(films)
            } catch {
                guard !Task.isCancelled else { return }
                filmsState = .failure(ErrorMapper.map(error))
            }
        }
        await refreshTask?.value
    }

    // User left the tab: cancel outstanding refresh work.
    func cancelRefresh() {
        refreshTask?.cancel()
    }

    // Heart button and list rows call this; removes/adds IDs and patches list state when possible.
    func toggleFavorite(filmID: String) {
        if favoriteIDs.contains(filmID) {
            favoriteIDs.remove(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            if case .success(let films) = filmsState {
                let next = films.filter { $0.id != filmID }
                filmsState = .success(next)
            }
        } else {
            favoriteIDs.insert(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            Task { await addFavoriteFilm(filmID: filmID) }
        }
    }

    func isFavorite(filmID: String) -> Bool {
        favoriteIDs.contains(filmID)
    }

    // After adding an ID, fetch that film once and merge into the current success list by title.
    private func addFavoriteFilm(filmID: String) async {
        do {
            let film = try await fetchFilmUseCase.execute(id: filmID)
            guard favoriteIDs.contains(filmID), !Task.isCancelled else { return }

            switch filmsState {
            case .success(let films):
                var next = films.filter { $0.id != filmID }
                next.append(film)
                filmsState = .success(next.sorted {
                    $0.title.localizedStandardCompare($1.title) == .orderedAscending
                })
            case .idle, .loading, .failure:
                await refreshFilms()
            }
        } catch {
            favoriteIDs.remove(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            await refreshFilms()
        }
    }

    static var mock: FavoritesViewModel {
        let catalog = MockFilmCatalogRepository()
        let vm = FavoritesViewModel(
            repository: MockFavoritesRepository(),
            fetchFilmUseCase: FetchFilmUseCase(repository: catalog),
            fetchFavoriteFilmsUseCase: FetchFavoriteFilmsUseCase(repository: catalog)
        )
        vm.loadIDs()
        vm.filmsState = .success(Film.mocks)
        return vm
    }
}
