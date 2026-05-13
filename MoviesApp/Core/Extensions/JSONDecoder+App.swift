//
//  JSONDecoder+App.swift
//  MoviesApp
//

import Foundation

extension JSONDecoder {
    // Single decoder configuration shared by `URLSessionHTTPClient` and any manual decode sites.
    static let app: JSONDecoder = {
        let d = JSONDecoder()
        // DTOs define `CodingKeys` per property instead of relying on automatic snake_case conversion.
        d.keyDecodingStrategy = .useDefaultKeys
        // API date fields that use ISO-8601 strings decode into `Date` when models ask for them.
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
