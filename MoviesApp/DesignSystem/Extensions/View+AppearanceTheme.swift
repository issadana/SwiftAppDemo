//
//  View+AppearanceTheme.swift
//  MoviesApp
//
//  View extension applying `preferredColorScheme` from saved `AppearanceTheme`.

import SwiftUI

extension View {
    // Reads `AppearanceTheme` from UserDefaults and applies the matching `preferredColorScheme`.
    func setAppearanceTheme() -> some View {
        // `ViewModifier` — Reusable bundle of view-layer state + styling applied via `.modifier(...)`.
        modifier(AppearanceThemeModifier())
    }
}

private struct AppearanceThemeModifier: ViewModifier {
    // `@AppStorage` inside a modifier keeps theme reactive anywhere `.setAppearanceTheme()` is attached (here: tab shell).
    @AppStorage(UserDefaultsKeys.appearanceTheme) private var appearanceTheme: AppearanceTheme = .system

    // `Content` — The child view being wrapped; modifiers compose by transforming `content`.
    func body(content: Content) -> some View {
        // `.preferredColorScheme` — SwiftUI hint that overrides system appearance when theme is `.light`/`.dark`; `nil` means follow system.
        content.preferredColorScheme(appearanceTheme.colorScheme)
    }
}
