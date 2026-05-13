//
//  AppearanceTheme.swift
//  MoviesApp
//
//  Light/dark/system appearance choice persisted for the UI.

import SwiftUI

// Light/dark/system preference stored in UserDefaults and driven by SettingsScreen.
enum AppearanceTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// Centralised UserDefaults key strings; avoids magic string duplication across the app.
enum UserDefaultsKeys {
    static let appearanceTheme = "MoviesApp.Appearance.Theme"
    static let username = "MoviesApp.User.Username"
    static let itemsPerPage = "MoviesApp.Prefs.ItemsPerPage"
    static let notificationsEnabled = "MoviesApp.Prefs.NotificationsEnabled"
}
