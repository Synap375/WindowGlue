//
//  Window_GlueApp.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import SwiftUI
import Cocoa

class MenuBarIconManager: ObservableObject {
    @Published var dropIcon: NSImage
    @Published var glueActive: Bool = false
    @Published var canUnglue: Bool = false
    @Published var showingSettings: Bool = false
    @Published var shouldShowOnboarding: Bool = false
    
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
    
    func checkOnboarding() {
        shouldShowOnboarding = !settings.hasCompletedOnboarding
    }
}

@main
struct Window_GlueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var iconManager = MenuBarIconManager.shared
    
    init() {
        // Check onboarding status on app launch
        DispatchQueue.main.async {
            MenuBarIconManager.shared.checkOnboarding()
        }
    }
    
    static func setMenuBarIcon(active: Bool) {
        MenuBarIconManager.shared.setMenuBarIcon(active: active)
    }
    
    var body: some Scene {
        MenuBarExtra{
            MenuBarView()
        } label: {
            Image(nsImage: iconManager.dropIcon)
        }
        
        Window("Window Glue Settings", id: "settings") {
            SettingsWindow()
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 200)
        .windowToolbarStyle(.unifiedCompact)
        
        Window("Welcome to Window Glue", id: "onboarding") {
            OnboardingWindow()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 400)
    }
}
