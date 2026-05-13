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
        Logger.debug("FavoritesViewModel initialized", category: "FavoritesViewModel")
    }

    // Loads IDs from disk (or mock) without fetching full `Film` models.
    func loadIDs() {
        Logger.info("Loading favorite IDs from repository", category: "FavoritesViewModel")
        favoriteIDs = repository.load()
        Logger.debug("Loaded \(favoriteIDs.count) favorite IDs", category: "FavoritesViewModel")
    }

    // Fetches catalog entries for every stored ID in parallel; shows loading and errors inline.
    func refreshFilms() async {
        Logger.info("Starting films refresh", category: "FavoritesViewModel")
        refreshTask?.cancel()
        loadIDs()

        guard !favoriteIDs.isEmpty else {
            Logger.info("No favorite IDs found, setting empty success state", category: "FavoritesViewModel")
            filmsState = .success([])
            return
        }

        refreshTask = Task {
            filmsState = .loading
            Logger.debug("Fetching \(favoriteIDs.count) favorite films", category: "FavoritesViewModel")
            do {
                let films = try await fetchFavoriteFilmsUseCase.execute(favoriteIDs: favoriteIDs)
                guard !Task.isCancelled else {
                    Logger.debug("Refresh task was cancelled", category: "FavoritesViewModel")
                    return
                }
                filmsState = .success(films)
                Logger.info(
                    "Successfully refreshed \(films.count) favorite films",
                    category: "FavoritesViewModel"
                )
            } catch {
                guard !Task.isCancelled else { return }
                let appError = ErrorMapper.map(error)
                filmsState = .failure(appError)
                Logger.error(
                    "Failed to refresh favorite films: \(error.localizedDescription)",
                    category: "FavoritesViewModel"
                )
            }
        }
        await refreshTask?.value
    }

    // User left the tab: cancel outstanding refresh work.
    func cancelRefresh() {
        Logger.debug("Cancelling refresh task", category: "FavoritesViewModel")
        refreshTask?.cancel()
    }

    // Heart button and list rows call this; removes/adds IDs and patches list state when possible.
    func toggleFavorite(filmID: String) {
        if favoriteIDs.contains(filmID) {
            Logger.info("Removing film from favorites: \(filmID)", category: "FavoritesViewModel")
            favoriteIDs.remove(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            if case .success(let films) = filmsState {
                let next = films.filter { $0.id != filmID }
                filmsState = .success(next)
                Logger.debug("Updated films list after removal, count: \(next.count)", category: "FavoritesViewModel")
            }
        } else {
            Logger.info("Adding film to favorites: \(filmID)", category: "FavoritesViewModel")
            favoriteIDs.insert(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            Task { await addFavoriteFilm(filmID: filmID) }
        }
    }

    func isFavorite(filmID: String) -> Bool {
        let isFav = favoriteIDs.contains(filmID)
        Logger.debug("Checking if film is favorite: \(filmID) = \(isFav)", category: "FavoritesViewModel")
        return isFav
    }

    // After adding an ID, fetch that film once and merge into the current success list by title.
    private func addFavoriteFilm(filmID: String) async {
        Logger.debug("Adding new favorite film to list: \(filmID)", category: "FavoritesViewModel")
        do {
            let film = try await fetchFilmUseCase.execute(id: filmID)
            guard favoriteIDs.contains(filmID), !Task.isCancelled else {
                Logger.debug("Film was removed before fetch completed or task cancelled", category: "FavoritesViewModel")
                return
            }

            switch filmsState {
            case .success(let films):
                var next = films.filter { $0.id != filmID }
                next.append(film)
                filmsState = .success(next.sorted {
                    $0.title.localizedStandardCompare($1.title) == .orderedAscending
                })
                Logger.debug(
                    "Successfully added film '\(film.title)' to favorites list",
                    category: "FavoritesViewModel"
                )
            case .idle, .loading, .failure:
                Logger.info("State not success, refreshing full list", category: "FavoritesViewModel")
                await refreshFilms()
            }
        } catch {
            Logger.error(
                "Failed to add favorite film \(filmID): \(error.localizedDescription)",
                category: "FavoritesViewModel"
            )
            favoriteIDs.remove(filmID)
            repository.save(favoriteIDs: favoriteIDs)
            await refreshFilms()
        }
    }

    static var mock: FavoritesViewModel {
        Logger.debug("Creating mock FavoritesViewModel", category: "FavoritesViewModel")
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
