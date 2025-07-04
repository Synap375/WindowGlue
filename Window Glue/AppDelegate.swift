//
//  AppDelegate.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 03.07.2025.
//

import Cocoa
import AXSwift
import Swindler

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
//        checkAccessibilityPermissions()
        guard AXSwift.checkIsProcessTrusted(prompt: true) else {
            showAccessibilityAlert()
            return
        }
        Swindler.initialize().done { state/* -> Promise<Void>*/ in
            state.on { (event: WindowFrameChangedEvent) in
                guard event.external == true else { return }
                if glueActive {
                    for w in state.knownWindows {
//                        if w != event.window && showOverlayRectangle(for: w, position: compareRects(w.frame.value, event.window.frame.value), draggedWindow: event.window) {
//                            break
//                        }
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
