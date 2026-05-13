//
//  URLSessionHTTPClient.swift
//  MoviesApp
//

import Foundation

// Production implementation: GET JSON, map status codes and errors to `NetworkError`.
struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = URLSessionHTTPClient.makeSession(),
        decoder: JSONDecoder = .app
    ) {
        self.session = session
        self.decoder = decoder
    }

    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConstants.API.timeoutSeconds
        return URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ urlString: String, as type: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 422:
            throw NetworkError.unprocessable
        case 500...599:
            throw NetworkError.serverError(http.statusCode)
        default:
            throw NetworkError.invalidResponse
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}
