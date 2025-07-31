//
//  CompanionsTabView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//

// CompanionsTabView.swift
import SwiftUI

struct CompanionsTabView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    // We need a timer here too for the hatchling countdown
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    
    var body: some View {
        NavigationView {
            ScrollView { 
                VStack(spacing: 20) {
                    
                    MenuSection(title: "Scout Activity") {
                        if gameManager.activeBaseUpgrades.contains(.scoutsQuarters) {
                            HStack {
                                Text("Current Assignment:")
                                Spacer()
                                Text(gameManager.assignedScoutTask?.displayName ?? "Random Basic")
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Build Scouts' Quarters to dispatch scouts.").foregroundColor(.secondary)
                        }
                    }
                    
                    if let activeCreature = gameManager.activeCreature {
                        MenuSection(title: "Active Companion") {
                            // Display the right view based on the active pet's state
                            switch activeCreature.state {
                            case .hatchling:
                                HatchlingRowView(gameManager: gameManager, creature: activeCreature, currentTime: currentTime)
                            case .untrainedAdult:
                                QuestRowView(gameManager: gameManager, creature: activeCreature)
                            case .trainedAdult:
                                CreatureRowView(gameManager: gameManager, creature: activeCreature, currentTime: currentTime)
                            }
                        }
                    }
                    
                    MenuSection(title: "All Companions") {
                        if gameManager.ownedCreatures.isEmpty {
                            Text("No companions yet. Find eggs by chopping trees!").foregroundColor(.secondary)
                        } else {
                            ForEach(gameManager.ownedCreatures) { creature in
                                // This provides a simpler summary view for the list
                                CompanionSummaryRow(creature: creature)
                                Divider()
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Companions")
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
        .onReceive(timer) { newTime in
            self.currentTime = newTime
        }
    }
}

// A new, simpler row for the list in this tab to avoid clutter.
struct CompanionSummaryRow: View {
    let creature: Creature
    
    private var statusText: String {
        switch creature.state {
        case .hatchling: return "Hatchling"
        case .untrainedAdult: return "Untrained - Quest Active"
        case .trainedAdult: return "Trained"
        }
    }
    
    private var statusColor: Color {
        switch creature.state {
        case .hatchling: return .secondary
        case .untrainedAdult: return .blue
        case .trainedAdult: return .green
        }
    }
    
    var body: some View {
        HStack {
            Image("\(creature.type.rawValue)_icon")
                .resizable().scaledToFit().frame(width: 32, height: 32)
            
            Text(creature.name ?? creature.type.displayName)
                .font(.headline)
            
            Spacer()
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
        }
    }
}
