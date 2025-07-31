//
//  PotionsInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// PotionsInventoryView.swift
import SwiftUI

struct PotionsInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private var sortedPotions: [ItemType] {
        ItemType.allCases.filter { item in
            // Check if it's a potion AND the player has at least one in inventory.
            return item.potionEffect != nil && (gameManager.sanctumItemStorage[item] ?? 0) > 0
        }.sorted { $0.tier < $1.tier }
    }
    
    var body: some View {
        List {
            Section(header: Text("Potions")) {
                if sortedPotions.isEmpty {
                    Text("No potions crafted yet.").foregroundColor(.secondary)
                } else {
                    ForEach(sortedPotions) { potion in
                        Button(action: { selectedInspectableItem = .item(potion) }) {
                            // Assuming you have a PotionRowView helper
                            PotionRowView(potionItem: potion, count: gameManager.sanctumItemStorage[potion] ?? 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Potions")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}
