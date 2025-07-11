//
//  Position.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import Cocoa
import Swindler

extension CGRect {
    func withMinX(_ newMinX: CGFloat) -> CGRect {
        let diff = newMinX - self.minX
        return CGRect(origin: CGPoint(x: newMinX, y: self.minY), size: CGSize(width: self.width - diff, height: self.height))
    }
    
    func withMaxX(_ newMaxX: CGFloat) -> CGRect {
        let diff = newMaxX - self.maxX
        return CGRect(origin: CGPoint(x: self.minX, y: self.minY), size: CGSize(width: self.width + diff, height: self.height))
    }
    
    func withMinY(_ newMinY: CGFloat) -> CGRect {
        let diff = newMinY - self.minY
        return CGRect(origin: CGPoint(x: self.minX, y: newMinY), size: CGSize(width: self.width, height: self.height - diff))
    }
    
    func withMaxY(_ newMaxY: CGFloat) -> CGRect {
        let diff = newMaxY - self.maxY
        return CGRect(origin: CGPoint(x: self.minX, y: self.minY), size: CGSize(width: self.width, height: self.height + diff))
    }
}

enum Position {
    case left
    case right
    case bottom
    case top
    case none
    
    func opposite() -> Position {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        case .bottom:
            return .top
        case .top:
            return .bottom
        case .none:
            return .none
        }
    }
}

func gluePosition(_ rect1: CGRect, _ rect2: CGRect) -> Position {
    let tolerance = CGFloat(settings.tolerance)
    // Check if rect2's left edge is within tolerance of rect1's right edge
    if abs(rect2.minX - rect1.maxX) <= tolerance {
        // Check vertical alignment - smaller rect shouldn't extend beyond bigger rect by more than tolerance
        let rect1Height = rect1.height
        let rect2Height = rect2.height
        if rect1Height < rect2Height {
            if rect1.minY < rect2.minY - tolerance || rect1.maxY > rect2.maxY + tolerance {
                return .none
            }
        } else {
            if rect2.minY < rect1.minY - tolerance || rect2.maxY > rect1.maxY + tolerance {
                return .none
            }
        }
        return .right
    }
    // Check if rect2's right edge is within tolerance of rect1's left edge
    if abs(rect2.maxX - rect1.minX) <= tolerance {
        // Check vertical alignment - smaller rect shouldn't extend beyond bigger rect by more than tolerance
        let rect1Height = rect1.height
        let rect2Height = rect2.height
        if rect1Height < rect2Height {
            if rect1.minY < rect2.minY - tolerance || rect1.maxY > rect2.maxY + tolerance {
                return .none
            }
        } else {
            if rect2.minY < rect1.minY - tolerance || rect2.maxY > rect1.maxY + tolerance {
                return .none
            }
        }
        return .left
    }
    // Check if rect2's bottom edge is within tolerance of rect1's top edge
    if abs(rect2.minY - rect1.maxY) <= tolerance {
        // Check horizontal alignment - smaller rect shouldn't extend beyond bigger rect by more than tolerance
        let rect1Width = rect1.width
        let rect2Width = rect2.width
        if rect1Width < rect2Width {
            if rect1.minX < rect2.minX - tolerance || rect1.maxX > rect2.maxX + tolerance {
                return .none
            }
        } else {
            if rect2.minX < rect1.minX - tolerance || rect2.maxX > rect1.maxX + tolerance {
                return .none
            }
        }
        return .top
    }
    // Check if rect2's top edge is within tolerance of rect1's bottom edge
    if abs(rect2.maxY - rect1.minY) <= tolerance {
        // Check horizontal alignment - smaller rect shouldn't extend beyond bigger rect by more than tolerance
        let rect1Width = rect1.width
        let rect2Width = rect2.width
        if rect1Width < rect2Width {
            if rect1.minX < rect2.minX - tolerance || rect1.maxX > rect2.maxX + tolerance {
                return .none
            }
        } else {
            if rect2.minX < rect1.minX - tolerance || rect2.maxX > rect1.maxX + tolerance {
                return .none
            }
        }
        return .bottom
    }
    return .none
}

func oneSideChanged(_ rect1: CGRect, _ rect2: CGRect) -> Position {
    let topChanged = rect1.maxY != rect2.maxY
    let bottomChanged = rect1.minY != rect2.minY
    let leftChanged = rect1.minX != rect2.minX
    let rightChanged = rect1.maxX != rect2.maxX
    
    if topChanged && !bottomChanged && !leftChanged && !rightChanged {
        return .top
    } else if bottomChanged && !topChanged && !leftChanged && !rightChanged {
        return .bottom
    } else if leftChanged && !rightChanged && !topChanged && !bottomChanged {
        return .left
    } else if rightChanged && !leftChanged && !topChanged && !bottomChanged{
        return .right
    }
    return .none
}

func attachWindow(_ window: Swindler.Window, to staticWindow: Swindler.Window, position: Position) {
    print(position)
    reposition(window, to: staticWindow, position: position)
    windowGlues.append((window, position, staticWindow))
    windowGlues.append((staticWindow, position.opposite(), window))
    MenuBarIconManager.shared.updateCanUnglue()
    glueActive = false
    Window_GlueApp.setMenuBarIcon(active: false)
}

func reposition(_ window: Swindler.Window, to staticWindow: Swindler.Window, position: Position) {
    let newRect: CGRect
    switch position {
    case .top:
        newRect = CGRect(x: staticWindow.frame.value.minX, y: staticWindow.frame.value.maxY,
                             width: staticWindow.frame.value.width, height: window.frame.value.height)
    case .bottom:
        newRect = CGRect(x: staticWindow.frame.value.minX, y: staticWindow.frame.value.minY -  window.frame.value.height,
                             width: staticWindow.frame.value.width, height: window.frame.value.height)
    case .left:
        newRect = CGRect(x: staticWindow.frame.value.minX - window.frame.value.width, y: staticWindow.frame.value.minY,
                             width: window.frame.value.width, height: staticWindow.frame.value.height)
    case .right:
        newRect = CGRect(x: staticWindow.frame.value.maxX, y: staticWindow.frame.value.minY,
                             width: window.frame.value.width, height: staticWindow.frame.value.height)
    default:
        return
    }
    _ = window.frame.set(newRect)
}

func repositionSplit(_ window: Swindler.Window, to staticWindow: Swindler.Window, position: Position) {
    let newRect: CGRect
    switch position {
    case .top:
        newRect = window.frame.value.withMinY(staticWindow.frame.value.maxY)
    case .bottom:
        newRect = window.frame.value.withMaxY(staticWindow.frame.value.minY)
    case .left:
        newRect = window.frame.value.withMaxX(staticWindow.frame.value.minX)
    case .right:
        newRect = window.frame.value.withMinX(staticWindow.frame.value.maxX)
    default:
        return
    }
    _ = window.frame.set(newRect)
}
