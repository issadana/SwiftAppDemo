//
//  Film.swift
//  MoviesApp
//

import Foundation

// Domain model for a Ghibli film; value type safe to pass across actors and use in `NavigationPath`.
struct Film: Identifiable, Equatable, Hashable, Sendable {
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

    // Lightweight fixtures for unit tests and mock repositories (no asset bundle).
    static let mock = Film(
        id: "mock-totoro",
        title: "My Neighbor Totoro",
        description: "Two sisters encounter friendly forest spirits in rural Japan.",
        director: "Hayao Miyazaki",
        producer: "Toru Hara",
        releaseYear: "1988",
        score: "93",
        duration: "86",
        image: "",
        bannerImage: "",
        people: []
    )

    static let mockFavorite = Film(
        id: "2baf70d1-42bb-4437-b551-e5fed5a87abe",
        title: "Castle in the Sky",
        description: "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa.",
        director: "Hayao Miyazaki",
        producer: "Toru Hara",
        releaseYear: "1986",
        score: "95",
        duration: "124",
        image: "",
        bannerImage: "",
        people: []
    )

    static let mocks: [Film] = [mock, mockFavorite]

    // Rich previews: depends on UIKit helper that materializes asset JPEGs as file URLs.
    @MainActor
    static var example: Film {
        let bannerURL = URL.convertAssetImage(named: "bannerImage")
        let posterURL = URL.convertAssetImage(named: "posterImage")
        return Film(
            id: "id",
            title: "My Neighbor Totoro",
            description: "Two sisters encounter friendly forest spirits in rural Japan.",
            director: "Hayao Miyazaki",
            producer: "Toru Hara",
            releaseYear: "1988",
            score: "93",
            duration: "86",
            image: posterURL?.absoluteString ?? "",
            bannerImage: bannerURL?.absoluteString ?? "",
            people: ["https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"]
        )
    }

    @MainActor
    static var exampleFavorite: Film {
        let bannerURL = URL.convertAssetImage(named: "bannerImage")
        let posterURL = URL.convertAssetImage(named: "posterImage")
        return Film(
            id: "2baf70d1-42bb-4437-b551-e5fed5a87abe",
            title: "Castle in the Sky",
            description: "The orphan Sheeta inherited a mysterious crystal that links her to the mythical sky-kingdom of Laputa. With the help of resourceful Pazu and a rollicking band of sky pirates, she makes her way to the ruins of the once-great civilization.",
            director: "Hayao Miyazaki",
            producer: "Toru Hara",
            releaseYear: "1986",
            score: "95",
            duration: "124",
            image: posterURL?.absoluteString ?? "",
            bannerImage: bannerURL?.absoluteString ?? "",
            people: ["https://ghibliapi.vercel.app/people/598f7048-74ff-41e0-92ef-87dc1ad980a9"]
        )
    }
}
