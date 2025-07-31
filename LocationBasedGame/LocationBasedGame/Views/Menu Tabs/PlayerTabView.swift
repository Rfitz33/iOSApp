//
//  PlayerTabView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


// PlayerTabView.swift
import SwiftUI

struct PlayerTabView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    // --- NEW: State variables required by EquippedGearSection ---
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil
    @State private var slotToEquip: EquipmentSlot? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // The storage overview, moved from the old InventoryView
                    StorageOverviewSection(gameManager: gameManager)
                    
                    EquippedGearSection(
                        gameManager: gameManager,
                        selectedInspectableItem: $selectedInspectableItem,
                        slotToEquip: $slotToEquip
                    )
                    
                    MenuSection(title: "Inventory Categories") {
                        // Using our new custom styled links
                        InventoryCategoryLink(
                            title: "Tools",
                            systemImage: "hammer",
                            destination: ToolsInventoryView(gameManager: gameManager)
                        )
                        
                        Divider() // Add dividers for better visual separation
                        
                        InventoryCategoryLink(
                            title: "Bags & Satchels",
                            systemImage: "briefcase",
                            destination: BagsInventoryView(gameManager: gameManager)
                        )
                        
                        Divider()

                        InventoryCategoryLink(
                            title: "Resources",
                            systemImage: "leaf",
                            destination: ResourcesInventoryView(gameManager: gameManager)
                        )

                        Divider()

                        InventoryCategoryLink(
                            title: "Components",
                            systemImage: "wrench.and.screwdriver",
                            destination: ComponentsInventoryView(gameManager: gameManager)
                        )

                        Divider()

                        InventoryCategoryLink(
                            title: "Jewelry",
                            systemImage: "sparkle",
                            destination: JewelryInventoryView(gameManager: gameManager)
                        )

                        Divider()

                        InventoryCategoryLink(
                            title: "Potions",
                            systemImage: "testtube.2",
                            destination: PotionsInventoryView(gameManager: gameManager)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Player & Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedInspectableItem) { inspectableItem in
                            ItemDetailView(gameManager: gameManager, inspectableItem: inspectableItem)
            }
            .sheet(item: $slotToEquip) { slot in
                EquipmentPickerView(gameManager: gameManager, slot: slot)
            }
        }
        .navigationViewStyle(.stack)
    }
}
