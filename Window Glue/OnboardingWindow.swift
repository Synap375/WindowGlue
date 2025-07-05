//
//  OnboardingWindow.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 04.07.2025.
//

import SwiftUI

struct OnboardingWindow: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Window Glue",
            description: "Snap windows together with intuitive drag gestures. Create organized workspace layouts effortlessly.",
            systemImage: "rectangle.3.group"
        ),
        OnboardingPage(
            title: "How to Use",
            description: "1. Toggle 'Add Glue' in the menu bar\n2. Drag any window near another window\n3. Watch the glow indicator appear\n4. Release to glue windows together",
            systemImage: "hand.draw"
        ),
        OnboardingPage(
            title: "Shake to Unglue",
            description: "Shake any window quickly back and forth to unglue all connected windows. You can disable this in settings.",
            systemImage: "iphone.gen3.radiowaves.left.and.right"
        ),
        OnboardingPage(
            title: "Ready to Start",
            description: "You're all set! Access settings and controls from the menu bar icon. Happy window management!",
            systemImage: "checkmark.circle.fill"
        )
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Page content
            VStack(spacing: 20) {
                Image(systemName: pages[currentPage].systemImage)
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text(pages[currentPage].title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(pages[currentPage].description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Navigation
            VStack(spacing: 16) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Buttons
                HStack {
                    if currentPage > 0 {
                        Button("Previous") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Get Started") {
                            settings.hasCompletedOnboarding = true
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding(40)
        .frame(width: 500, height: 400)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String
}
