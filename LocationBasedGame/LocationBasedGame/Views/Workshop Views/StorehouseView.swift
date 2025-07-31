//
//  StorehouseView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

// StorehouseView.swift
import SwiftUI

struct StorehouseView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss

    // We can define the bonus per level here.
    private var materialEfficiencyBonus: Double {
        // Example: 2% chance per level. For now, we only have one level.
        // In the future, you would check gameManager.storehouseLevel
        return gameManager.activeBaseUpgrades.contains(.basicStorehouse) ? 0.02 : 0.0
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- Header ---
                    VStack(spacing: 8) {
                        Image("storehouse_icon")
                            .resizable().scaledToFit().frame(height: 80)
                        Text("Storehouse")
                            .font(.largeTitle.bold())
                        Text("A well-organized space for all your processed materials and crafted gear.")
                            .font(.subheadline).foregroundColor(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                    .padding(.vertical)

                    // --- Benefit 1: Unlimited Storage ---
                    MenuSection(title: "Sanctum Workshop Storage") {
                        HStack(alignment: .top) {
                            Image(systemName: "infinity.circle.fill")
                                .font(.title)
                                .foregroundColor(.indigo)
                            
                            VStack(alignment: .leading) {
                                Text("Components & Items: UNLIMITED")
                                    .font(.headline)
                                Text("Building the Storehouse provides unlimited space for all your processed components and crafted items, freeing up valuable carry capacity.")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // --- Benefit 2: Material Efficiency ---
                    MenuSection(title: "Logistics Bonus") {
                        HStack(alignment: .top) {
                            Image(systemName: "sparkles.square.filled.on.square")
                                .font(.title)
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading) {
                                Text("Material Efficiency: \(materialEfficiencyBonus * 100, specifier: "%.0f")%")
                                    .font(.headline)
                                Text("Your organized storage provides a \(materialEfficiencyBonus * 100, specifier: "%.0f")% chance to not consume an ingredient when crafting any item or component.")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Placeholder for future upgrades
                    // MenuSection(title: "Future Upgrades") { ... }
                }
                .padding()
            }
            .background(
                Image("storehouse_background")
                    .resizable().scaledToFill().edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3))
            )
            .navigationTitle("Storehouse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}


// --- MARK: - Preview Provider (Updated) ---
struct StorehouseView_Previews: PreviewProvider {
    class MockStorehouseGameManager: GameManager {
        override init() {
            super.init()
            self.activeBaseUpgrades.insert(.basicStorehouse)
        }
    }
    
    static var previews: some View {
        StorehouseView(gameManager: MockStorehouseGameManager())
    }
}
