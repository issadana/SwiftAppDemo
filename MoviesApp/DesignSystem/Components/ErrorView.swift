//
//  ErrorView.swift
//  MoviesApp
//

import SwiftUI

// Full-area error with optional retry; `isRetryable` hides the button for validation-style failures.
struct ErrorView: View {
    let error: AppError
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text(error.errorDescription ?? "")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if error.isRetryable, let retryAction {
                Button("Retry", action: retryAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.md)
    }
}

#Preview {
    ErrorView(error: .network(.noInternet)) {
        print("retry")
    }
}
