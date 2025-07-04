//
//  Position.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import Cocoa

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

func compareRects(_ rect1: CGRect, _ rect2: CGRect) -> Position {
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
