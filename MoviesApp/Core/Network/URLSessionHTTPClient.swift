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
        Logger.debug("URLSessionHTTPClient initialized", category: "HTTPClient")
    }

    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConstants.API.timeoutSeconds
        return URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ urlString: String, as type: T.Type) async throws -> T {
        Logger.info("Fetching data from: \(urlString)", category: "HTTPClient")
        
        guard let url = URL(string: urlString) else {
            Logger.error("Invalid URL: \(urlString)", category: "HTTPClient")
            throw NetworkError.invalidURL
        }

        let data: Data
        let response: URLResponse

        do {
            Logger.debug("Starting URLSession.data(from:) request", category: "HTTPClient")
            (data, response) = try await session.data(from: url)
            Logger.debug("Received response with \(data.count) bytes", category: "HTTPClient")
        } catch let urlError as URLError {
            Logger.error("URLError occurred: \(urlError.code)", category: "HTTPClient")
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                Logger.error("Network connectivity issue", category: "HTTPClient")
                throw NetworkError.noInternet
            case .timedOut:
                Logger.error("Request timed out after \(AppConstants.API.timeoutSeconds)s", category: "HTTPClient")
                throw NetworkError.timeout
            default:
                Logger.error("URLError: \(urlError.localizedDescription)", category: "HTTPClient")
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        }

        guard let http = response as? HTTPURLResponse else {
            Logger.error("Response is not HTTPURLResponse", category: "HTTPClient")
            throw NetworkError.invalidResponse
        }

        Logger.debug("HTTP Status Code: \(http.statusCode)", category: "HTTPClient")

        switch http.statusCode {
        case 200...299:
            Logger.debug("Success response (\(http.statusCode))", category: "HTTPClient")
            break
        case 401:
            Logger.warning("Unauthorized (401)", category: "HTTPClient")
            throw NetworkError.unauthorized
        case 403:
            Logger.warning("Forbidden (403)", category: "HTTPClient")
            throw NetworkError.forbidden
        case 404:
            Logger.warning("Not Found (404)", category: "HTTPClient")
            throw NetworkError.notFound
        case 422:
            Logger.warning("Unprocessable Entity (422)", category: "HTTPClient")
            throw NetworkError.unprocessable
        case 500...599:
            Logger.error("Server error (\(http.statusCode))", category: "HTTPClient")
            throw NetworkError.serverError(http.statusCode)
        default:
            Logger.error("Unexpected status code: \(http.statusCode)", category: "HTTPClient")
            throw NetworkError.invalidResponse
        }

        do {
            Logger.debug("Attempting to decode response as \(type)", category: "HTTPClient")
            let decodedValue = try decoder.decode(type, from: data)
            Logger.debug("Successfully decoded response", category: "HTTPClient")
            return decodedValue
        } catch {
            Logger.error("Decoding failed: \(error.localizedDescription)", category: "HTTPClient")
            throw NetworkError.decoding
        }
    }
}
