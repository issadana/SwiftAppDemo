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
    }

    // First appearance kicks off parallel person fetches for each URL on `film.people`.
    func onAppear() async {
        guard case .idle = state else { return }
        await fetchPeople()
    }

    func cancelFetch() {
        fetchTask?.cancel()
    }

    private func fetchPeople() async {
        fetchTask?.cancel()
        fetchTask = Task {
            state = .loading
            do {
                let people = try await fetchPeopleUseCase.execute(film: film)
                guard !Task.isCancelled else { return }
                state = .success(people)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(ErrorMapper.map(error))
            }
        }
        await fetchTask?.value
    }
}
