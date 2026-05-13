//
//  SettingsScreen.swift
//  MoviesApp
//

import SwiftUI

struct SettingsScreen: View {
    @AppStorage(UserDefaultsKeys.appearanceTheme)
    private var appearanceTheme: AppearanceTheme = .system

    @AppStorage(UserDefaultsKeys.username)
    private var username: String = ""

    @AppStorage(UserDefaultsKeys.itemsPerPage)
    private var itemsPerPage: Int = 20

    @AppStorage(UserDefaultsKeys.notificationsEnabled)
    private var notificationsEnabled: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Appearance", selection: $appearanceTheme) {
                        ForEach(AppearanceTheme.allCases) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose light, dark, or match the system setting.")
                }

                Section("Account") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Preferences") {
                    Stepper("Items per page: \(itemsPerPage)", value: $itemsPerPage, in: 10...100, step: 5)
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                }

                Section {
                    Button(role: .destructive) {
                        resetDefaults()
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func resetDefaults() {
        appearanceTheme = .system
        username = ""
        itemsPerPage = 20
        notificationsEnabled = true
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
