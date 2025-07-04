//
//  BorderView.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import Cocoa
import Swindler

var windowDict: [Swindler.Window : NSWindow] = [:]
var windowGlues: [(Swindler.Window, Position, Swindler.Window)] = []

class BorderView: NSView {
    let position: Position
    
    init(position: Position) {
        self.position = position
        super.init(frame: NSZeroRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let indicatorImage = NSImage(named: "Indicator") else {
            return
        }
        
        let accentColor = NSColor.controlAccentColor
        
        let bottomBorderRect = NSRect(x: 0, y: 0, width: bounds.width, height: indicatorImage.size.height)
        switch position {
        case .bottom:
            indicatorImage.draw(in: bottomBorderRect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
            accentColor.set()
            bottomBorderRect.fill(using: .sourceAtop)
        case .top:
//            let topBorderRect = NSRect(x: 0, y: bounds.height - indicatorImage.size.height, width: bounds.width, height: indicatorImage.size.height)
            NSGraphicsContext.current?.saveGraphicsState()
            let topTransform = NSAffineTransform()
            topTransform.translateX(by: 0, yBy: bounds.height)
            topTransform.scaleX(by: 1.0, yBy: -1.0)
            topTransform.concat()
            indicatorImage.draw(in: bottomBorderRect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
            accentColor.set()
            bottomBorderRect.fill(using: .sourceAtop)
            NSGraphicsContext.current?.restoreGraphicsState()
        case .left:
//            let leftBorderRect = NSRect(x: 0, y: 0, width: indicatorImage.size.height, height: bounds.height)
            NSGraphicsContext.current?.saveGraphicsState()
            let leftTransform = NSAffineTransform()
            leftTransform.translateX(by: 0, yBy: bounds.height)
            leftTransform.rotate(byDegrees: -90)
            leftTransform.concat()
            let leftDrawRect = NSRect(x: 0, y: 0, width: bounds.height, height: indicatorImage.size.height)
            indicatorImage.draw(in: leftDrawRect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
            accentColor.set()
            leftDrawRect.fill(using: .sourceAtop)
            NSGraphicsContext.current?.restoreGraphicsState()
        case .right:
//            let rightBorderRect = NSRect(x: bounds.width - indicatorImage.size.height, y: 0, width: indicatorImage.size.height, height: bounds.height)
            NSGraphicsContext.current?.saveGraphicsState()
            let rightTransform = NSAffineTransform()
            rightTransform.translateX(by: bounds.width, yBy: 0)
            rightTransform.rotate(byDegrees: 90)
            rightTransform.concat()
            let rightDrawRect = NSRect(x: 0, y: 0, width: bounds.height, height: indicatorImage.size.height)
            indicatorImage.draw(in: rightDrawRect, from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
            accentColor.set()
            rightDrawRect.fill(using: .sourceAtop)
            NSGraphicsContext.current?.restoreGraphicsState()
        case .none:
            break
        }
    }
}

func showOverlayRectangle(for window: Swindler.Window, position: Position, draggedWindow: Swindler.Window) -> Bool {
    if position == .none {
        if let w = windowDict[window] {
            w.orderOut(nil)
            windowDict.removeValue(forKey: window)
        }
        return false
    } else if windowDict[window] != nil {
        return true
    }
    
    let overlayWindow = NSWindow(
        contentRect: NSRect(origin: CGPointZero, size: window.frame.value.size),
        styleMask: [.borderless],
        backing: .buffered,
        defer: false
    )
    windowDict[window] = overlayWindow
    
    let borderView = BorderView(position: position)
    overlayWindow.contentView = borderView
    overlayWindow.backgroundColor = NSColor.clear
    overlayWindow.level = .screenSaver
    overlayWindow.isOpaque = false
    overlayWindow.hasShadow = false
    overlayWindow.ignoresMouseEvents = true
    overlayWindow.setFrameOrigin(window.frame.value.origin)
    overlayWindow.orderFront(nil)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        overlayWindow.contentView?.alphaValue = 0
        guard windowDict[window] != nil else { return }
        _ = window.application.mainWindow.set(window)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            guard windowDict[window] != nil else { return }
            overlayWindow.contentView?.alphaValue = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                overlayWindow.contentView?.alphaValue = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    guard windowDict[window] != nil else { return }
                    overlayWindow.contentView?.alphaValue = 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        overlayWindow.orderOut(nil)
                        if windowDict[window] != nil {
                            windowDict.removeValue(forKey: window)
                            attachWindow(draggedWindow, to: window, position: position)
                        }
                    }
                }
            }
        }
    }
    return true
}
