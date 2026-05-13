//
//  FilmDetailViewModel.swift
//  MoviesApp
//

import Foundation
import Observation

// Detail screen state: immutable `Film` plus async-loaded related `Person` rows.
@Observable
@MainActor
final class FilmDetailViewModel {
    let film: Film
    private(set) var state: ViewState<[Person]> = .idle

    private let fetchPeopleUseCase: FetchPeopleForFilmUseCaseProtocol
    private var fetchTask: Task<Void, Never>?

    init(film: Film, fetchPeopleUseCase: FetchPeopleForFilmUseCaseProtocol) {
        self.film = film
        self.fetchPeopleUseCase = fetchPeopleUseCase
        Logger.debug("FilmDetailViewModel initialized for film: \(film.title)", category: "FilmDetailViewModel")
    }

    // First appearance kicks off parallel person fetches for each URL on `film.people`.
    func onAppear() async {
        Logger.debug("FilmDetailViewModel.onAppear() called for film: \(film.title)", category: "FilmDetailViewModel")
        guard case .idle = state else {
            Logger.debug("State is not idle, skipping fetch", category: "FilmDetailViewModel")
            return
        }
        await fetchPeople()
    }

    func cancelFetch() {
        Logger.debug("Cancelling person fetch for film: \(film.title)", category: "FilmDetailViewModel")
        fetchTask?.cancel()
    }

    private func fetchPeople() async {
        Logger.info("Fetching people for film: \(film.title)", category: "FilmDetailViewModel")
        fetchTask?.cancel()
        fetchTask = Task {
            state = .loading
            Logger.debug("State changed to loading", category: "FilmDetailViewModel")
            do {
                let people = try await fetchPeopleUseCase.execute(film: film)
                guard !Task.isCancelled else {
                    Logger.debug("Fetch people task was cancelled", category: "FilmDetailViewModel")
                    return
                }
                state = .success(people)
                Logger.info(
                    "Successfully loaded \(people.count) people for film: \(film.title)",
                    category: "FilmDetailViewModel"
                )
            } catch {
                guard !Task.isCancelled else { return }
                let appError = ErrorMapper.map(error)
                state = .failure(appError)
                Logger.error(
                    "Failed to fetch people for \(film.title): \(error.localizedDescription)",
                    category: "FilmDetailViewModel"
                )
            }
        }
        await fetchTask?.value
    }
}
