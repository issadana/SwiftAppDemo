//
//  LoadingState.swift
//  MoviesApp
//

import Foundation

// Generic wrapper for async screen state: idle → loading → value or mapped error.
enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case success(T)
    case failure(AppError)

    // Convenience for showing spinners without pattern matching everywhere.
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    // Extracts the payload when `.success`, else `nil`.
    var data: T? {
        if case .success(let value) = self { return value }
        return nil
    }

    // Extracts `AppError` when `.failure`, else `nil`.
    var error: AppError? {
        if case .failure(let error) = self { return error }
        return nil
    }
}
