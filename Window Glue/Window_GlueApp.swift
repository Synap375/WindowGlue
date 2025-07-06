//
//  Window_GlueApp.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import SwiftUI
import Cocoa
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleGlue = Self("toggleGlue", default: .init(.f9, modifiers: []))
    static let unglue = Self("unglue", default: .init(.f9, modifiers: [.shift]))
}

class MenuBarIconManager: ObservableObject {
    @Published var dropIcon: NSImage
    @Published var glueActive: Bool = false
    @Published var canUnglue: Bool = false
    @Published var showingSettings: Bool = false
    @Published var showingAbout: Bool = false
    
    static let shared = MenuBarIconManager()
    
    private init() {
        let menuBarIcon = NSImage(size: NSSize(width: 16, height: 16))
        if let icon16 = NSImage(named: "drop-inactive-16") {
            for rep in icon16.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        if let icon18 = NSImage(named: "drop-inactive-18") {
            for rep in icon18.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        if let icon20 = NSImage(named: "drop-inactive-20") {
            for rep in icon20.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        menuBarIcon.isTemplate = true
        dropIcon = menuBarIcon
    }
    
    func setMenuBarIcon(active: Bool) {
        let menuBarIcon = NSImage(size: NSSize(width: 16, height: 16))
        let iconPrefix = active ? "drop-" : "drop-inactive-"
        
        if let icon16 = NSImage(named: "\(iconPrefix)16") {
            for rep in icon16.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        if let icon18 = NSImage(named: "\(iconPrefix)18") {
            for rep in icon18.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        if let icon20 = NSImage(named: "\(iconPrefix)20") {
            for rep in icon20.representations {
                menuBarIcon.addRepresentation(rep)
            }
        }
        menuBarIcon.isTemplate = true
        
        dropIcon = menuBarIcon
        glueActive = active
    }
    
    func updateCanUnglue() {
        canUnglue = !windowGlues.isEmpty
    }
    
    func showSettings() {
        showingSettings = true
    }
    
    func showAbout() {
        showingAbout = true
    }
}

struct MenuBarContentView: View {
    @ObservedObject private var iconManager = MenuBarIconManager.shared
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Toggle("Add Glue", isOn: $iconManager.glueActive)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: iconManager.glueActive) { newValue in
                    glueActive = newValue
                    iconManager.setMenuBarIcon(active: newValue)
                }
            Button("Unglue Active Window") {
                guard swindlerState != nil else { return }
                guard let w = swindlerState!.frontmostApplication.value?.mainWindow.value else { return }
                windowGlues.removeAll(where: { $0.0 == w || $0.2 == w })
                MenuBarIconManager.shared.updateCanUnglue()
            }
            .disabled(!iconManager.canUnglue)
            Button("Unglue All") {
                windowGlues = []
                MenuBarIconManager.shared.updateCanUnglue()
            }
            .disabled(!iconManager.canUnglue)
            
            Divider()
            
            Button("Settings...") {
                iconManager.showSettings()
            }
            Button("About Window Glue") {
                iconManager.showAbout()
            }
            
            Menu("My Other Apps") {
                Button("Folders File Manager") {
                    NSWorkspace.shared.open(URL(string: "https://foldersapp.dev/?ref=wg")!)
                }
            }
            Divider()
            
            Button("Quit Window Glue") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

@main
struct Window_GlueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var iconManager = MenuBarIconManager.shared
    @Environment(\.openWindow) private var openWindow
    
    static func setMenuBarIcon(active: Bool) {
        MenuBarIconManager.shared.setMenuBarIcon(active: active)
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
        } label: {
            Image(nsImage: iconManager.dropIcon)
        }
        .onChange(of: iconManager.showingSettings) { showSettings in
            if showSettings {
                openWindow(id: "settings")
                iconManager.showingSettings = false
            }
        }
        .onChange(of: iconManager.showingAbout) { showAbout in
            if showAbout {
                openWindow(id: "about")
                iconManager.showingAbout = false
            }
        }
        
        Window(String(localized: "Window Glue Settings"), id: "settings") {
            SettingsWindow()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 350, height: 230)
        .windowToolbarStyle(.unifiedCompact)
        
        Window(String(localized: "About Window Glue"), id: "about") {
            AboutWindow()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 320, height: 280)
    }
}
