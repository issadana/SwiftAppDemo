//
//  FilmImageView.swift
//  MoviesApp
//
//  Async poster/banner image from API URL or preview asset URL.

import SwiftUI

// Async-loaded poster or banner; supports API string URLs and preview `URL`s from assets.
struct FilmImageView: View {
    let url: URL?

    init(urlPath: String) {
        url = URL(string: urlPath)
    }

    init(url: URL?) {
        self.url = url
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Color(white: 0.8)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                    }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
            case .failure:
                Text("Could not get image")
            @unknown default:
                fatalError()
            }
        }
    }
}

#Preview("poster image") {
    FilmImageView(url: URL.convertAssetImage(named: "posterImage"))
        .frame(height: 150)
}

#Preview("banner image") {
    let name = "bannerImage"
    let url = URL.convertAssetImage(named: name)
    FilmImageView(url: url)
        .frame(height: 300)
}
