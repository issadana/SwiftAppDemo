//
//  EmptyStateView.swift
//  MoviesApp
//
//  Centered empty-state illustration with title and optional subtitle.

import SwiftUI

// Centered placeholder when `ViewState` is idle or there is no data to show yet.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.md)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "heart",
        title: "No favorites yet",
        subtitle: "Save films from the Movies tab."
    )
}
