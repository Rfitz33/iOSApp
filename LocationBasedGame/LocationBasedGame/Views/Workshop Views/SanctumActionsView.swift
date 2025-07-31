//
//  SanctumActionsView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/19/25.
//


// SanctumActionsView.swift
import SwiftUI

struct SanctumActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil

    // MARK: - Data Preparation
    
    // --- Components Crafted Here (Tier 0) ---
    private var organizedComponents: [CraftingSection] {
        // We will manually define the T0 components for this station.
        let tierZeroComponents: [ComponentType] = [
            .T0_axeHandle, .T0_axeHead, .T0_pickaxeH, .T0_knifeHandle, .T0_knifeBlade
        ]
        
        // No skill level check needed for T0 items.
        let filtered = tierZeroComponents.filter { component in
            showOnlyCraftable ? gameManager.canCraftComponent(component) : true
        }.sorted { $0.tier < $1.tier } // Sorting is good practice
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Tool Component Crafting", components: filtered)]
    }
    
    // --- Items Assembled Here (Tier 0) ---
    private var organizedItems: [ItemCraftingSection] {
        let tierZeroItems: [ItemType] = [
            .T0_pickaxe, .T0_axe, .T0_huntingKnife
        ]
        
        let filtered = tierZeroItems.filter { item in
            showOnlyCraftable ? gameManager.canCraftItem(item) : true
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [ItemCraftingSection(title: "Basic Tool Assembly", items: filtered)]
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable)
                    .padding(.horizontal)
                
                List {
                    // --- Render Component Sections ---
                    ForEach(organizedComponents) { section in
                        Section(header: Text(section.title)) {
                            ForEach(section.components) { component in
                                ComponentRecipeRow(
                                    gameManager: gameManager,
                                    component: component,
                                    requiredSkill: .carpentry,
                                    onCraft: { craftedComponent in
                                    // When a craft happens, update our state
                                        self.lastCraftedComponent = craftedComponent
                                        self.lastCraftedItem = nil // Clear the other type
                                    }
                                )
                                .zIndex(component == lastCraftedComponent ? 1 : 0)
                            }
                        }
                    }
                    
                    // --- Render Item Sections ---
                    ForEach(organizedItems) { section in
                        Section(header: Text(section.title)) {
                            ForEach(section.items) { item in
                                ItemRecipeRow(
                                    gameManager: gameManager,
                                    item: item,
                                    onCraft: { craftedItem in
                                        self.lastCraftedItem = craftedItem
                                        self.lastCraftedComponent = nil // Clear the other type
                                    }
                                )
                                .zIndex(item == lastCraftedItem ? 1 : 0)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(
                Image("sanctum_background") // <-- A unique background for the main sanctum
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3))
            )
            .navigationTitle("Sanctum Workshop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Preview Provider
struct SanctumActionsView_Previews: PreviewProvider {
    class MockSanctumGameManager: GameManager {
        override init() {
            super.init()
            // Provide enough basic resources to craft makeshift tools
            self.playerInventory[.T0_wood] = 10
            self.playerInventory[.stone] = 10
        }
    }
    static var previews: some View {
        SanctumActionsView(gameManager: MockSanctumGameManager())
    }
}
