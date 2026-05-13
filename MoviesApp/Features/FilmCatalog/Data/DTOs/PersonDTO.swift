//
//  PersonDTO.swift
//  MoviesApp
//
//  Decodable person payload from the Ghibli HTTP API.

import Foundation

// JSON shape for `/people/:id` (or absolute people URLs referenced from a film payload).
struct PersonDTO: Decodable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let eyeColor: String
    let hairColor: String
    let films: [String]
    let species: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id, name, gender, age, films, species, url
        case eyeColor = "eye_color"
        case hairColor = "hair_color"
    }
}

extension PersonDTO {
    // Converts decoded JSON into a `Person` used by the film detail feature.
    func toDomain() -> Person {
        Person(
            id: id,
            name: name,
            gender: gender,
            age: age,
            eyeColor: eyeColor,
            hairColor: hairColor,
            films: films,
            species: species,
            url: url
        )
    }
}
