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
    }

    // Called from `.task` on first appearance; avoids duplicate full catalog fetches.
    func onAppear() async {
        guard case .idle = state else { return }
        await fetch()
    }

    // Loads or reloads films; previous in-flight work is cancelled first.
    func fetch() async {
        fetchTask?.cancel()
        fetchTask = Task {
            state = .loading
            do {
                let films = try await fetchFilmsUseCase.execute()
                guard !Task.isCancelled else { return }
                state = .success(films)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(ErrorMapper.map(error))
            }
        }
        await fetchTask?.value
    }

    // Stops network work when navigating away so late responses cannot flip state.
    func cancelFetch() {
        fetchTask?.cancel()
    }

    @MainActor
    static var mock: FilmsViewModel {
        let vm = FilmsViewModel(fetchFilmsUseCase: FetchFilmsUseCase(repository: MockFilmCatalogRepository()))
        vm.state = .success([Film.example, Film.exampleFavorite])
        return vm
    }
}
