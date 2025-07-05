//
//  ContentView.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import SwiftUI
import Cocoa
import Swindler

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct MenuBarView: View {
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
                openWindow(id: "settings")
            }
            
            Menu("More") {
                Button("About Window Glue") {
                    // About window
                }
                Button("My Other Apps") {
                    // TBD
                }
                
                #if DEBUG
                Divider()
                Button("Reset Onboarding & Quit") {
                    settings.hasCompletedOnboarding = false
                    NSApplication.shared.terminate(nil)
                }
                #endif
            }
            
            Divider()
            
            Button("Quit Window Glue") {
                NSApplication.shared.terminate(nil)
            }
        }
        .onReceive(iconManager.$shouldShowOnboarding) { shouldShow in
            if shouldShow {
                openWindow(id: "onboarding")
                iconManager.shouldShowOnboarding = false
            }
        }
    }
}

//func makeGrid() {
//    Swindler.initialize().then { state -> Promise<Void> in
//        let screen = state.screens.first!
//        
//        let allPlacedOnGrid = state.knownWindows.enumerated().map { index, window in
//            let rect = gridRect(screen: screen, index: index)
//            return window.frame.set(rect)
//        }
//        
//        return when(fulfilled: allPlacedOnGrid).done { _ in
//            print("All done")
//        }
//    }.catch { e in
//        print(e)
//    }
//}
//
//func gridRect(screen: Swindler.Screen, index: Int) -> CGRect {
//    let size = CGSize(width: screen.frame.width, height: screen.frame.height)
//    let position = CGPointZero
//    return CGRect(origin: position, size: size)
//}
