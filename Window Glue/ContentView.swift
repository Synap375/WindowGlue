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
    @State private var glueWindowsEnabled: Bool = false
    
    var body: some View {
            Toggle("Glue Windows", isOn: $glueWindowsEnabled)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .onChange(of: glueWindowsEnabled) { newValue in
                    glueActive = newValue
                    Window_GlueApp.setMenuBarIcon(active: newValue)
                }
            
            Divider()
            
            Button("About Window Glue") {
//                makeGrid()
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Button("Settings...") {
                // Settings action
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            Button("Quit Window Glue") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
