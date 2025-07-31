//
//  SettingsView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/26/25.
//


// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    // We need to pass the gameManager down to the dev tools.
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    MenuSection(title: "Game Settings") {
                        Text("Volume, Graphics, etc. - Coming Soon!")
                            .foregroundColor(.secondary)
                    }
                    
                    // --- This is where the developer tools are added ---
                    // We can use a compiler flag to ensure this section
                    // is completely removed from the final App Store build.
                    #if DEBUG
                    DeveloperToolsView(gameManager: gameManager)
                    #endif
                    
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}
