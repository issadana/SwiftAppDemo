//
//  Person.swift
//  MoviesApp
//
//  Domain person model (e.g. director) resolved from API URLs.

import Foundation

// Character record returned by the API and shown in the film detail sheet.
struct Person: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let gender: String
    let age: String
    let eyeColor: String
    let hairColor: String
    let films: [String]
    let species: String
    let url: String

    static let mock = Person(
        id: "mock-person-1",
        name: "Satsuki Kusakabe",
        gender: "Female",
        age: "11",
        eyeColor: "Brown",
        hairColor: "Black",
        films: [],
        species: "Human",
        url: ""
    )
}
