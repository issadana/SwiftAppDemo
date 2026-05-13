//
//  URL+ImageAssets.swift
//  MoviesApp
//
//  Preview-only `URL` helpers pointing at asset image names.

import UIKit

extension URL {
    // Writes a catalog image to the caches directory once so `AsyncImage` can load it like a remote URL.
    static func convertAssetImage(named name: String,
                                  extension: String = "jpg") -> URL? {
        let fileManager = FileManager.default

        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        let url = cacheDirectory.appendingPathComponent("\(name).\(`extension`)")

        guard !fileManager.fileExists(atPath: url.path) else {
            return url
        }

        guard let image = UIImage(named: name),
              let data = image.jpegData(compressionQuality: 1) else {
            return nil
        }

        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
        return url
    }
}
