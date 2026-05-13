//
//  RootDestination.swift
//  MoviesApp
//
//  Coarse app flow stage (extend for splash, auth, etc.).

import Foundation

// Coarse app-level stage; extend when you add splash, sign-in, or paywall flows.
enum RootDestination: Equatable {
    // Normal app: tabs, stacks, settings.
    case main
}
