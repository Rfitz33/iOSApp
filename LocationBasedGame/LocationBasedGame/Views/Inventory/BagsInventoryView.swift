//
//  BagsInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// BagsInventoryView.swift
import SwiftUI

struct BagsInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private var sortedBagsInInventory: [ItemType] {
        ItemType.allCases
            .filter { item in
                let slot = item.equipmentSlot
                // Check if it's a bag or satchel AND the player has at least one in inventory.
                return (slot == .backpack || slot == .satchel) && (gameManager.sanctumItemStorage[item] ?? 0) > 0
            }
            .sorted { $0.tier < $1.tier }
    }

    var body: some View {
        List {
            Section(header: Text("Bags & Satchels")) {
                if sortedBagsInInventory.isEmpty {
                    Text("No spare bags or satchels.").foregroundColor(.secondary)
                } else {
                    ForEach(sortedBagsInInventory) { bag in
                        Button(action: { selectedInspectableItem = .item(bag) }) {
                            // Using a simple row view for bags, as in your original file.
                            // This can be extracted to a helper view if desired.
                            HStack {
                                Image(bag.iconAssetName)
                                    .resizable().scaledToFit().frame(width: 28, height: 28)
                                VStack(alignment: .leading) {
                                    Text(bag.displayName)
                                    if bag.herbCapacityBonus > 0 {
                                        Text("+\(bag.herbCapacityBonus) Herb Capacity").font(.caption).foregroundColor(.green)
                                    }
                                    if bag.generalResourceCapacityBonus > 0 {
                                        Text("+\(bag.generalResourceCapacityBonus) General Capacity").font(.caption).foregroundColor(.blue)
                                    }
                                }
                                Spacer()
                                Text("x\(gameManager.sanctumItemStorage[bag] ?? 0)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("Bags & Satchels")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}
