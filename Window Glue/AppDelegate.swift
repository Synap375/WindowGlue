//
//  AppDelegate.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import Cocoa
import AXSwift
import Swindler
import KeyboardShortcuts
import SwiftUI

struct WindowMovement {
    let position: CGPoint
    let timestamp: Date
}

var swindlerState: Swindler.State? = nil

class AppDelegate: NSObject, NSApplicationDelegate {
    @ObservedObject private var iconManager = MenuBarIconManager.shared
    private var windowMovements: [Swindler.Window: [WindowMovement]] = [:]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard AXSwift.checkIsProcessTrusted(prompt: false) else {
            showAccessibilityAlert()
            return
        }
        
        KeyboardShortcuts.onKeyUp(for: .unglue) {
            guard swindlerState != nil else { return }
            guard let w = swindlerState!.frontmostApplication.value?.mainWindow.value else { return }
            windowGlues.removeAll(where: { $0.0 == w || $0.2 == w })
            MenuBarIconManager.shared.updateCanUnglue()
        }
        KeyboardShortcuts.onKeyUp(for: .toggleGlue) { [self] in
            glueActive.toggle()
            iconManager.setMenuBarIcon(active: glueActive)
        }
        
        Swindler.initialize().done { state/* -> Promise<Void>*/ in
            swindlerState = state
            state.on { (event: WindowFrameChangedEvent) in
                guard event.external == true else { return }
                
                // Track window movement for shake detection
                let currentPosition = event.window.frame.value.origin
                let currentTime = Date()
                
                // Initialize movement history for this window if needed
                if self.windowMovements[event.window] == nil {
                    self.windowMovements[event.window] = []
                }
                
                // Add current movement
                self.windowMovements[event.window]?.append(WindowMovement(position: currentPosition, timestamp: currentTime))
                
                // Keep only recent movements (last 2 seconds)
                let cutoffTime = currentTime.addingTimeInterval(-2.0)
                self.windowMovements[event.window] = self.windowMovements[event.window]?.filter { $0.timestamp >= cutoffTime }
                
                // Check for shake gesture
                if settings.shakeToUnglueEnabled && self.detectShakeGesture(for: event.window) {
                    windowGlues.removeAll(where: { $0.0 == event.window || $0.2 == event.window })
                    MenuBarIconManager.shared.updateCanUnglue()
                    // Clear movement history after shake detection
                    self.windowMovements[event.window] = []
                }
                
                if glueActive && windowGlues.filter({ $0.0 == event.window || $0.2 == event.window }).count == 0 {
                    for w in state.knownWindows {
                        if w != event.window {
                            if windowGlues.filter({ $0.0 == w || $0.2 == w }).count > 0 {
                                continue
                            }
                            if showOverlayRectangle(for: w, position: gluePosition(w.frame.value, event.window.frame.value), draggedWindow: event.window) {
                                break
                            }
                        }
                    }
                }
                for pair in windowGlues.filter({ $0.2 == event.window }) {
                    if oneSideChanged(event.newValue, event.oldValue) == pair.1 {
                        repositionSplit(pair.0, to: pair.2, position: pair.1)
                    } else {
                        reposition(pair.0, to: pair.2, position: pair.1)
                    }
                }
            }
            
            state.on { (event: WindowDestroyedEvent) in
                windowGlues.removeAll(where: { $0.0 == event.window || $0.2 == event.window })
                MenuBarIconManager.shared.updateCanUnglue()
            }
            
            state.on { (event: ApplicationTerminatedEvent) in
                windowGlues.removeAll(where: { $0.0.application == event.application || $0.2.application == event.application })
                MenuBarIconManager.shared.updateCanUnglue()
            }
            
            state.on { (event: FrontmostApplicationChangedEvent) in
                guard event.external == true else { return }
                for pair in windowGlues.filter({ $0.2 == event.newValue?.mainWindow.value }) {
                    if pair.0.application == pair.2.application { continue }
                    _ = swindlerState?.frontmostApplication.set(pair.0.application).done { _ in
                        _ = pair.0.application.mainWindow.set(pair.0).done { _ in
                            _ = swindlerState?.frontmostApplication.set(event.newValue!)
                        }
                    }
                }
            }
            
            state.on { (event: WindowMinimizedChangedEvent) in
                guard event.external == true else { return }
                for pair in windowGlues.filter({ $0.2 == event.window }) {
                    _ = pair.0.isMinimized.set(event.newValue)
                }
            }
            
            state.on { (event: ApplicationIsHiddenChangedEvent) in
                windowGlues.removeAll(where: { $0.0.application == event.application || $0.2.application == event.application })
            }
            
            state.on { (event: ApplicationMainWindowChangedEvent) in
                guard event.external == true else { return }
                for pair in windowGlues.filter({ $0.2 == event.application.mainWindow.value }) {
                    if pair.0.application == pair.2.application { continue }
                    _ = swindlerState?.frontmostApplication.set(pair.0.application).done { _ in
                        _ = pair.0.application.mainWindow.set(pair.0).done { _ in
                            _ = swindlerState?.frontmostApplication.set(event.application)
                        }
                    }
                }
            }
        }.catch { e in
            print(e)
        }
    }
    
    private func detectShakeGesture(for window: Swindler.Window) -> Bool {
        guard let movements = windowMovements[window], movements.count >= 6 else {
            return false
        }
        
        // Check if we have enough rapid movements in the last 1 second
        let recentTime = Date().addingTimeInterval(-1.0)
        let recentMovements = movements.filter { $0.timestamp >= recentTime }
        
        guard recentMovements.count >= 4 else {
            return false
        }
        
        // Check for back-and-forth movement pattern
        var directionChanges = 0
        var previousDirection: CGPoint?
        
        for i in 1..<recentMovements.count {
            let current = recentMovements[i].position
            let previous = recentMovements[i-1].position
            
            let movement = CGPoint(x: current.x - previous.x, y: current.y - previous.y)
            let distance = sqrt(movement.x * movement.x + movement.y * movement.y)
            
            // Only consider movements that are significant enough
            guard distance > 5 else { continue }
            
            // Normalize movement direction
            let normalizedMovement = CGPoint(x: movement.x / distance, y: movement.y / distance)
            
            if let prevDir = previousDirection {
                // Check if direction changed significantly (dot product < 0 means opposite directions)
                let dotProduct = normalizedMovement.x * prevDir.x + normalizedMovement.y * prevDir.y
                if dotProduct < -0.5 {
                    directionChanges += 1
                }
            }
            
            previousDirection = normalizedMovement
        }
        
        // Consider it a shake if we have at least 3 direction changes in rapid succession
        return directionChanges >= 3
    }
    
    private func showAccessibilityAlert() {
        self.showAccessibilityAlertInternal(hasOpenedSettings: false)
    }
    
    private func showAccessibilityAlertInternal(hasOpenedSettings: Bool) {
        let alert = NSAlert()
        alert.messageText = String(localized: "Accessibility Permission Required")
        alert.informativeText = String(localized: "Window Glue needs accessibility permissions to manage windows. Please enable it in System Settings > Privacy & Security > Accessibility, then quit and relaunch Window Glue.")
        alert.alertStyle = .warning
        
        if !hasOpenedSettings {
            alert.addButton(withTitle: String(localized: "Open System Settings"))
            alert.addButton(withTitle: String(localized: "Cancel"))
            alert.addButton(withTitle: String(localized: "Quit and Relaunch"))
        } else {
            alert.addButton(withTitle: String(localized: "Cancel"))
            alert.addButton(withTitle: String(localized: "Quit and Relaunch"))
        }
        
        let response = alert.runModal()
        
        if !hasOpenedSettings && response == .alertFirstButtonReturn {
            // Open System Settings but don't close the dialog
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            // Wait a moment to allow System Settings to come forward, then show dialog again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !AXSwift.checkIsProcessTrusted(prompt: false) {
                    self.showAccessibilityAlertInternal(hasOpenedSettings: true)
                }
            }
        } else if (!hasOpenedSettings && response == .alertSecondButtonReturn) || (hasOpenedSettings && response == .alertFirstButtonReturn) {
            // Cancel - continue without permissions
            return
        } else if (!hasOpenedSettings && response == .alertThirdButtonReturn) || (hasOpenedSettings && response == .alertSecondButtonReturn) {
            // Quit and Relaunch
            let appPath = Bundle.main.bundlePath
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [appPath]
            task.launch()
            NSApplication.shared.terminate(nil)
        }
    }
}
