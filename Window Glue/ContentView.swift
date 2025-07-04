//
//  ContentView.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import SwiftUI
//import Swindler
//import PromiseKit
import Cocoa

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
    
    var body: some View {
        Toggle("Add Glue", isOn: $iconManager.glueActive)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .onChange(of: iconManager.glueActive) { newValue in
                glueActive = newValue
                iconManager.setMenuBarIcon(active: newValue)
            }
        
        Divider()
        
        Button("Settings...") {
            // Settings action
        }
        
        Menu("More") {
            Button("About Window Glue") {
                // Settings action
            }
            Button("My Other Apps") {
                // Settings action
            }
        }
        
        Divider()
        
        Button("Quit Window Glue") {
            NSApplication.shared.terminate(nil)
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
