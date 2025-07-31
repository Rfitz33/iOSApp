//
//  SanctumTabView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//

// SanctumTabView.swift
import SwiftUI

struct SanctumTabView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- Active Timers & Status Section ---
                    activeTimersSection
                    
                    MenuSection(title: "Sanctum Status") {
                        // Using a more structured Grid for better alignment
                        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 12) {
                            GridRow {
                                Text("Forge:")
                                Text(gameManager.activeBaseUpgrades.contains(.basicForge) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.basicForge) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Woodworking Shop:")
                                Text(gameManager.activeBaseUpgrades.contains(.woodworkingShop) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.woodworkingShop) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Tanning Rack:")
                                Text(gameManager.activeBaseUpgrades.contains(.tanningRack) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.tanningRack) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Apothecary Stand:")
                                Text(gameManager.activeBaseUpgrades.contains(.apothecaryStand) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.apothecaryStand) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Fletching Shop:")
                                Text(gameManager.activeBaseUpgrades.contains(.fletchingWorkshop) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.fletchingWorkshop) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Jewelcrafting:")
                                Text(gameManager.activeBaseUpgrades.contains(.jewelCraftingWorkshop) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.jewelCraftingWorkshop) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Alchemy Lab:")
                                Text(gameManager.activeBaseUpgrades.contains(.alchemyLab) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.alchemyLab) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Storehouse:")
                                Text(gameManager.activeBaseUpgrades.contains(.basicStorehouse) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.basicStorehouse) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Garden:")
                                Text(gameManager.activeBaseUpgrades.contains(.garden) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.garden) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Scouts' Quarters:")
                                Text(gameManager.activeBaseUpgrades.contains(.scoutsQuarters) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.scoutsQuarters) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Watchtower:")
                                Text(gameManager.activeBaseUpgrades.contains(.watchtower) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.watchtower) ? .green : .secondary)
                            }
                            GridRow {
                                Text("Aviary:")
                                Text(gameManager.activeBaseUpgrades.contains(.aviary) ? "Built" : "Not Built")
                                    .foregroundColor(gameManager.activeBaseUpgrades.contains(.aviary) ? .green : .secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Sanctum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onReceive(timer) { newTime in
                self.currentTime = newTime
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private var activeTimersSection: some View {
        MenuSection(title: "Active Processes") {
            VStack(alignment: .leading, spacing: 12) {
                // --- 1. Scout Status ---
                if gameManager.activeBaseUpgrades.contains(.scoutsQuarters) {
                    if let timer = gameManager.scoutsGatherTimer {
                        // The StatusRow now takes the Date object directly
                        StatusRow(
                            icon: "figure.walk.motion",
                            iconColor: .brown,
                            title: "Scout Expedition",
                            statusPrefix: "Returning in:",
                            date: timer.fireDate, // Pass the Date
                            statusColor: .green
                        )
                    } else {
                        StatusRow(
                            icon: "figure.stand",
                            iconColor: .gray,
                            title: "Scout Expedition",
                            status: "Idle",
                            statusColor: .secondary
                        )
                    }
                }
                
                // --- 2. Watchtower Discovery Status ---
                if gameManager.activeBaseUpgrades.contains(.watchtower),
                   let discoveryID = gameManager.activeDiscoveryNodeID,
                   let discoveryNode = gameManager.activeResourceNodes.first(where: { $0.id == discoveryID }) {
                    
                    StatusRow(
                        icon: "binoculars.fill",
                        iconColor: .yellow,
                        title: "Bountiful Discovery",
                        statusPrefix: "\(discoveryNode.type.displayName) active for:",
                        date: discoveryNode.despawnTime, // Pass the Date
                        statusColor: .yellow
                    )
                }
                
                // --- 3. Aviary Incubation Status ---
                if gameManager.activeBaseUpgrades.contains(.aviary),
                   !gameManager.incubatingSlots.isEmpty {
                    
                    ForEach(gameManager.incubatingSlots) { slot in
                        // First, calculate when the egg will be ready to hatch.
                        let hatchReadyTime = slot.incubationStartTime.addingTimeInterval(slot.creatureType?.incubationTime ?? 0)
                        // Then, calculate the time remaining.
                        let remaining = hatchReadyTime.timeIntervalSinceNow
                        
                        StatusRow(
                            icon: slot.eggType.inventoryIconAssetName,
                            isAssetIcon: true,
                            title: "\(slot.eggType.displayName)",
                            statusPrefix: "Hatching in:",
                            // Pass the hatchReadyTime, not a variable that doesn't exist.
                            date: remaining > 0 ? hatchReadyTime : nil,
                            readyText: "Ready to Hatch!",
                            statusColor: remaining > 0 ? .cyan : .green
                        )
                    }
                }
                
                // --- 4. Garden Harvest Status (Placeholder for when we build it) ---
                // if gameManager.activeBaseUpgrades.contains(.garden) {
                //     StatusRow(icon: "leaf.fill", iconColor: .green, title: "Garden", status: "Ready to Harvest in: 02h 15m", statusColor: .green)
                // }
            }
        }
    }
}
    
    
    // --- NEW: A reusable helper view for consistent timer rows ---
struct StatusRow: View {
    let icon: String
    var isAssetIcon: Bool = false
    var iconColor: Color? = nil // Optional color
    let title: String
    
    // --- MODIFIED PROPERTIES ---
    var status: String? = nil
    var statusPrefix: String? = nil
    var date: Date? = nil
    var readyText: String? = nil
    
    let statusColor: Color
    
    var body: some View {
        HStack {
            if isAssetIcon {
                Image(icon)
                    .resizable().scaledToFit().frame(width: 24, height: 24)
            } else {
                Image(systemName: icon)
                    .font(.title3).foregroundColor(iconColor).frame(width: 24)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                // --- NEW DYNAMIC TEXT LOGIC ---
                HStack(spacing: 4) {
                    if let prefix = statusPrefix {
                        Text(prefix)
                    }
                    if let date = date {
                        // This is the correct way to use the .timer style
                        Text(date, style: .timer)
                    } else if let readyText = readyText {
                        Text(readyText)
                    } else if let status = status {
                        Text(status)
                    }
                }
                .font(.caption)
                .foregroundColor(statusColor)
            }
            Spacer()
        }
    }
}
