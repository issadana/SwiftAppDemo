//
//  AppError.swift
//  MoviesApp
//

import Foundation

// Low-level transport/decoding failures thrown by `URLSessionHTTPClient` and repositories.
enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decoding
    case noInternet
    case timeout
    case unauthorized
    case forbidden
    case notFound
    case unprocessable
    case serverError(Int)
    case unknown(String)

    // Plain-language message suitable for `Text` in the UI layer.
    var userMessage: String {
        switch self {
        case .invalidURL: return "The URL is invalid."
        case .invalidResponse: return "Invalid response from server."
        case .decoding: return "Failed to decode response."
        case .noInternet: return "No internet connection. Check your network and try again."
        case .timeout: return "The request timed out. Please try again."
        case .unauthorized: return "You do not have access to this content."
        case .forbidden: return "Access was denied."
        case .notFound: return "The requested resource could not be found."
        case .unprocessable: return "The server could not process this request."
        case .serverError: return "A server error occurred. Please try again later."
        case .unknown(let m): return m
        }
    }
}

// App-wide error surface for view models (`LocalizedError` bridges into SwiftUI easily).
enum AppError: LocalizedError, Equatable {
    case network(NetworkError)
    case validation(String)
    case unauthorized
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .network(let e): return e.userMessage
        case .validation(let m): return m
        case .unauthorized: return "Your session has expired. Sign in again to continue."
        case .notFound: return "The requested content could not be found."
        case .unknown: return "Something went wrong. Please try again."
        }
    }

    // Drives whether `ErrorView` shows a Retry button.
    var isRetryable: Bool {
        switch self {
        case .network(.noInternet), .network(.timeout), .network(.serverError):
            return true
        default:
            return false
        }
    }
}

// Normalizes `URLError`, `DecodingError`, and nested types into `AppError` for the presentation layer.
enum ErrorMapper {
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError { return appError }

        if let netError = error as? NetworkError {
            switch netError {
            case .unauthorized:
                return .unauthorized
            case .notFound:
                return .notFound
            default:
                return .network(netError)
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .network(.noInternet)
            case .timedOut:
                return .network(.timeout)
            default:
                return .network(.unknown(urlError.localizedDescription))
            }
        }

        if error is DecodingError {
            return .network(.decoding)
        }

        return .unknown
    }
}
