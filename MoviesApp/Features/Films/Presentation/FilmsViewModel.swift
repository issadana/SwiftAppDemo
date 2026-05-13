//
//  FilmsViewModel.swift
//  MoviesApp
//

import Foundation
import Observation

// Screen model for the main catalog list: one fetch, cancellable if the view leaves.
@Observable
@MainActor
final class FilmsViewModel {
    // Published to `FilmsScreen` for switch-based UI (empty, loading, list, error).
    private(set) var state: ViewState<[Film]> = .idle

    private let fetchFilmsUseCase: FetchFilmsUseCaseProtocol
    private var fetchTask: Task<Void, Never>?

    init(fetchFilmsUseCase: FetchFilmsUseCaseProtocol) {
        self.fetchFilmsUseCase = fetchFilmsUseCase
        Logger.debug("FilmsViewModel initialized", category: "FilmsViewModel")
    }

    // Called from `.task` on first appearance; avoids duplicate full catalog fetches.
    func onAppear() async {
        Logger.debug("FilmsViewModel.onAppear() called", category: "FilmsViewModel")
        guard case .idle = state else {
            Logger.debug("State is not idle, skipping fetch", category: "FilmsViewModel")
            return
        }
        await fetch()
    }

    // Loads or reloads films; previous in-flight work is cancelled first.
    func fetch() async {
        Logger.info("Fetching films catalog", category: "FilmsViewModel")
        fetchTask?.cancel()
        fetchTask = Task {
            state = .loading
            Logger.debug("State changed to loading", category: "FilmsViewModel")
            do {
                let films = try await fetchFilmsUseCase.execute()
                guard !Task.isCancelled else {
                    Logger.debug("Fetch task was cancelled", category: "FilmsViewModel")
                    return
                }
                state = .success(films)
                Logger.info(
                    "Successfully loaded \(films.count) films",
                    category: "FilmsViewModel"
                )
            } catch {
                guard !Task.isCancelled else { return }
                let appError = ErrorMapper.map(error)
                state = .failure(appError)
                Logger.error(
                    "Failed to fetch films: \(error.localizedDescription)",
                    category: "FilmsViewModel"
                )
            }
        }
        await fetchTask?.value
    }

    // Stops network work when navigating away so late responses cannot flip state.
    func cancelFetch() {
        Logger.debug("Cancelling fetch task", category: "FilmsViewModel")
        fetchTask?.cancel()
    }

    @MainActor
    static var mock: FilmsViewModel {
        Logger.debug("Creating mock FilmsViewModel", category: "FilmsViewModel")
        let vm = FilmsViewModel(fetchFilmsUseCase: FetchFilmsUseCase(repository: MockFilmCatalogRepository()))
        vm.state = .success([Film.example, Film.exampleFavorite])
        return vm
    }
}
