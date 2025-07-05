//
//  AppDelegate.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import Cocoa
import AXSwift
import Swindler

struct WindowMovement {
    let position: CGPoint
    let timestamp: Date
}

var swindlerState: Swindler.State? = nil

class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowMovements: [Swindler.Window: [WindowMovement]] = [:]
    func applicationDidFinishLaunching(_ notification: Notification) {
//        checkAccessibilityPermissions()
        
        // Show onboarding if first launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            MenuBarIconManager.shared.checkOnboarding()
        }
        
        guard AXSwift.checkIsProcessTrusted(prompt: true) else {
            showAccessibilityAlert()
            return
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
                
                if glueActive {
                    for w in state.knownWindows {
                        if w != event.window {
                            _ = showOverlayRectangle(for: w, position: compareRects(w.frame.value, event.window.frame.value), draggedWindow: event.window)
                        }
                    }
                }
                for pair in windowGlues.filter({ $0.2 == event.window }) {
                    reposition(pair.0, to: pair.2, position: pair.1)
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
    
//    private func checkAccessibilityPermissions() {
//        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
//        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
//        
//        if !accessibilityEnabled {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.showAccessibilityAlert()
//            }
//        }
//    }
//    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Window Glue needs accessibility permissions to manage windows. Please enable it in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}
