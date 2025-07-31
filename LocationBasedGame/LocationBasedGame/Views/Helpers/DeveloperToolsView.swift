//
//  DeveloperToolsView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/28/25.
//


// DeveloperToolsView.swift
import SwiftUI

struct DeveloperToolsView: View {
    @ObservedObject var gameManager: GameManager
    
    // State to manage the confirmation alerts
    @State private var activeAlert: AlertInfo? = nil
    
    // A helper struct for the alert info, kept local to this view
    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let messageText: String
        let primaryButtonText: String
        let action: () -> Void
    }

    var body: some View {
        MenuSection(title: "Developer Tools") {
            VStack(alignment: .leading, spacing: 10) {
                // We create a helper view for each button to reduce code duplication
                DevButton(title: "Clear Resources", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset all resources?",
                        primaryButtonText: "Reset Resources",
                        action: gameManager.clearInventoryForTesting
                    )
                }
                
                DevButton(title: "Clear Items/Tools", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset all items and tool durability?",
                        primaryButtonText: "Reset Items/Tools",
                        action: gameManager.clearItemInventoryForTesting
                    )
                }
                
                DevButton(title: "Clear Upgrades", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset all base upgrades?",
                        primaryButtonText: "Reset Upgrades",
                        action: gameManager.clearBaseUpgradesForTesting
                    )
                }
                
                DevButton(title: "Clear Skills XP", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset all skill experience?",
                        primaryButtonText: "Reset Skills XP",
                        action: gameManager.clearSkillsForTesting
                    )
                }
                
                DevButton(title: "Clear Scout Task", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset the scout assignment?",
                        primaryButtonText: "Reset Scout Task",
                        action: gameManager.clearScoutStateForTesting
                    )
                }
                
                DevButton(title: "Clear Active Potions", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset active potion effects?",
                        primaryButtonText: "Reset Active Potions",
                        action: gameManager.clearActivePotionEffectsForTesting
                    )
                }
                
                DevButton(title: "Clear Pets & Aviary", color: .orange) {
                    activeAlert = AlertInfo(
                        title: "Confirm Reset",
                        messageText: "Are you sure you want to reset all pets, eggs, and aviary progress?",
                        primaryButtonText: "Reset Pets",
                        action: gameManager.clearPetsForTesting
                    )
                }

                Divider().padding(.vertical, 5)

                DevButton(title: "RESET ALL PLAYER DATA", color: .red, isDestructive: true) {
                    activeAlert = AlertInfo(
                        title: "Confirm MASTER RESET",
                        messageText: "Are you sure you want to reset ALL player data? This action CANNOT BE UNDONE.",
                        primaryButtonText: "RESET EVERYTHING",
                        action: {
                            // Call all individual reset functions
                            gameManager.clearAllPlayerDataForTesting() // We will create this helper
                        }
                    )
                }
            }
        }
        .alert(item: $activeAlert) { alertInfo in
            Alert(
                title: Text(alertInfo.title),
                message: Text(alertInfo.messageText),
                primaryButton: .destructive(Text(alertInfo.primaryButtonText)) {
                    alertInfo.action()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

// --- Helper view for a consistent developer button style ---
struct DevButton: View {
    let title: String
    let color: Color
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(role: isDestructive ? .destructive : .none, action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundColor(color)
    }
}