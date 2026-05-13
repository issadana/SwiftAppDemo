//
//  FilmDTO.swift
//  MoviesApp
//

import Foundation

// JSON shape for `/films` responses; maps snake_case API keys to Swift property names.
struct FilmDTO: Decodable {
    let id: String
    let title: String
    let description: String
    let director: String
    let producer: String
    let releaseYear: String
    let score: String
    let duration: String
    let image: String
    let bannerImage: String
    let people: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, image, description, director, producer, people
        case bannerImage = "movie_banner"
        case releaseYear = "release_date"
        case duration = "running_time"
        case score = "rt_score"
    }
}

extension FilmDTO {
    // Maps wire-format fields to the app’s domain `Film` (same field names, no extra logic yet).
    func toDomain() -> Film {
        Film(
            id: id,
            title: title,
            description: description,
            director: director,
            producer: producer,
            releaseYear: releaseYear,
            score: score,
            duration: duration,
            image: image,
            bannerImage: bannerImage,
            people: people
        )
    }
}
