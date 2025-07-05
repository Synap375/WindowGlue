//
//  Settings.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import SwiftUI
import ServiceManagement

struct Settings {
    @AppStorage("tolerance") var tolerance: Int = 24
    @AppStorage("shakeToUnglueEnabled") var shakeToUnglueEnabled: Bool = true
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
}

var settings = Settings()
var glueActive: Bool = false

struct SettingsWindow: View {
    @State private var launchAtStartup = false
    @State private var localSettings = Settings()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("General")
                    .font(.headline)
                Toggle("Launch at startup", isOn: $launchAtStartup)
                    .onChange(of: launchAtStartup) { newValue in
                        setLaunchAtStartup(enabled: newValue)
                    }
                Toggle("Shake to unglue", isOn: $localSettings.shakeToUnglueEnabled)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
        .onAppear {
            launchAtStartup = isLaunchAtStartupEnabled()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

func isLaunchAtStartupEnabled() -> Bool {
    return SMAppService.mainApp.status == .enabled
}

func setLaunchAtStartup(enabled: Bool) {
    do {
        if enabled {
            try SMAppService.mainApp.register()
            print("SMAppService enabled")
        } else {
            try SMAppService.mainApp.unregister()
            print("SMAppService disabled")
        }
    } catch {
        print("Failed to \(enabled ? "enable" : "disable") launch at startup: \(error)")
    }
}
