//
//  JewelryInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// JewelryInventoryView.swift
import SwiftUI

struct JewelryInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private var sortedJewelry: [ItemType] {
        ItemType.allCases.filter { item in
            let slot = item.equipmentSlot
            // Check if it's a ring or necklace AND the player has at least one in inventory.
            return (slot == .ring || slot == .necklace) && (gameManager.sanctumItemStorage[item] ?? 0) > 0
        }.sorted { $0.tier < $1.tier }
    }

    var body: some View {
        List {
            Section(header: Text("Jewelry & Trinkets")) {
                if sortedJewelry.isEmpty {
                    Text("No jewelry crafted.").foregroundColor(.secondary)
                } else {
                    ForEach(sortedJewelry) { jewelry in
                        Button(action: { selectedInspectableItem = .item(jewelry) }) {
                            // Assuming you have a JewelryRowView helper from your old InventoryView
                            JewelryRowView(jewelryItem: jewelry, count: gameManager.sanctumItemStorage[jewelry] ?? 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Jewelry")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}
