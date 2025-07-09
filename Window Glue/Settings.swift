//
//  Settings.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import SwiftUI
import ServiceManagement
import KeyboardShortcuts

class Settings: ObservableObject {
    @AppStorage("tolerance") var tolerance: Int = 24
    @AppStorage("shakeToUnglueEnabled") var shakeToUnglueEnabled: Bool = true
}

var settings = Settings()
var glueActive: Bool = false

struct SettingsWindow: View {
    @State private var launchAtStartup = false
    @ObservedObject private var appSettings = settings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section() {
                    Toggle("Launch at startup:", isOn: $launchAtStartup)
                        .toggleStyle(.switch)
                        .onChange(of: launchAtStartup) { newValue in
                            setLaunchAtStartup(enabled: newValue)
                        }
                    Toggle("Shake to unglue:", isOn: $appSettings.shakeToUnglueEnabled)
                        .toggleStyle(.switch)
                    LabeledHStack("Snap tolerance:") {
                        HStack {
                            Slider(value: Binding(
                                get: { Double(appSettings.tolerance) },
                                set: { appSettings.tolerance = Int($0) }
                            ), in: 4...50)
                            Text("\(appSettings.tolerance) px")
                                .frame(width: 35, alignment: .trailing)
                                .monospacedDigit()
                        }
                    }
                } header: {
                    Text("General")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Section() {
                    KeyboardShortcuts.Recorder("Add Glue:", name: .toggleGlue)
                    KeyboardShortcuts.Recorder("Unglue active window:", name: .unglue)
                } header: {
                    Text("Keyboard Shortcuts")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 350, height: 240)
        .padding()
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

struct LabeledHStack<Content: View>: View {
    var label: LocalizedStringKey
    var content: () -> Content
    @State var labelWidth: CGFloat = 0

    init(_ label: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .multilineTextAlignment(.trailing)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .offset(x: 8.5)
                .readWidth { self.labelWidth = $0 }
            content()
                .padding([.leading], 1)
        }
        .alignmentGuide(.leading) { _ in labelWidth + 8 } // see note
    }
}


struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}


fileprivate extension View {
    func readWidth(onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: ceil(geometryProxy.size.width))
            }
        )
        .onPreferenceChange(WidthPreferenceKey.self) { k in
            DispatchQueue.main.async {
                onChange(k)
            }
        }
    }
}
