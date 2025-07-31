//
//  StatsTabView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//

// StatsTabView.swift
import SwiftUI

struct StatsTabView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // We wrap in a NavigationView to give it a title bar at the top.
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    MenuSection(title: "Player Summary") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading) {
                                Text("Adventurer") // This can be replaced with the player's name later
                                    .font(.title2.bold())
                                Text("Total Level: \(gameManager.totalPlayerLevel)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Total Experience Earned")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(gameManager.totalPlayerXP.formatted())
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    MenuSection(title: "Leaderboards") {
                        Text("Coming Soon!")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }

                }
                .padding()
            }
            .navigationTitle("Stats & Rankings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
