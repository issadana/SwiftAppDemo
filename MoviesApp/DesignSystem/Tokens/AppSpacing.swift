//
//  AppSpacing.swift
//  MoviesApp
//

// Layout constants use `CGFloat` for SwiftUI `.padding`, `spacing`, and frames.
import CoreGraphics

// Canonical spacing scale so screens stay visually consistent.
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // Size of the optional overlaid search control (tab system may still reserve this width).
    static let searchTabButtonSize: CGFloat = 56
}
