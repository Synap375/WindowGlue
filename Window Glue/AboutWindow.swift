//
//  AboutWindow.swift
//  Window Glue
//
//  Created by Andriy Konstantynov on 06.07.2025.
//
import SwiftUI

struct AboutWindow: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 12) {
            // App Icon and Name
            VStack(spacing: 8) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                
                Text("Window Glue")
                    .font(.title)
                    .fontWeight(.semibold)
                
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Version \(version) (\(build))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Credits and Links
            VStack(spacing: 8) {
                Text("Created by Andriy Konstantynov")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Made in Ukraine 🇺🇦")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Button("GitHub") {
                        NSWorkspace.shared.open(URL(string: "https://github.com/Conxt/WindowGlue")!)
                    }
                    .buttonStyle(.link)
                    
                    Button("Report Issue") {
                        NSWorkspace.shared.open(URL(string: "https://github.com/Conxt/WindowGlue/issues")!)
                    }
                    .buttonStyle(.link)
                }
            }
            
            Spacer()
            
            // Close button
            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
