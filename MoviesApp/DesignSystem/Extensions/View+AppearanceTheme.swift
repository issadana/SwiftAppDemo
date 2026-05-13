//
//  View+AppearanceTheme.swift
//  MoviesApp
//

import SwiftUI

extension View {
    // Reads `AppearanceTheme` from UserDefaults and applies the matching `preferredColorScheme`.
    func setAppearanceTheme() -> some View {
        modifier(AppearanceThemeModifier())
    }
}

private struct AppearanceThemeModifier: ViewModifier {
    @AppStorage(UserDefaultsKeys.appearanceTheme) private var appearanceTheme: AppearanceTheme = .system

    func body(content: Content) -> some View {
        content.preferredColorScheme(appearanceTheme.colorScheme)
    }
}
