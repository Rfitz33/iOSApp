//
//  JewelCraftingView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

// JewelCraftingView.swift
import SwiftUI

struct JewelCraftingView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil
    
    // MARK: - Data Preparation
    
    // --- Components Crafted Here (Cut Gemstones) ---
    private var organizedGems: [CraftingSection] {
        let jewelcraftingLevel = gameManager.getLevel(for: .jewelcrafting)
        let gemComponents = ComponentType.allCases.filter { $0.category == .jewelcrafting }
        
        let filtered = gemComponents.filter { component in
            let requiredLevel = component.requiredSkillLevel(for: .jewelcrafting)
            if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
            return jewelcraftingLevel >= requiredLevel || (requiredLevel - jewelcraftingLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Cut Gemstones", components: filtered)]
    }
    
    // --- Items Assembled Here (Rings & Necklaces) ---
    private var organizedJewelry: [ItemCraftingSection] {
        let jewelcraftingLevel = gameManager.getLevel(for: .jewelcrafting)
        
        // Define the sections and the items that belong to them
        let sections: [(title: String, items: [ItemType])] = [
            ("Rings", ItemType.allCases.filter { $0.equipmentSlot == .ring }),
            ("Necklaces", ItemType.allCases.filter { $0.equipmentSlot == .necklace })
        ]
        
        return sections.compactMap { title, items in
            let filtered = items.filter { item in
                let requiredLevel = item.recipe?.requiredSkillLevel(for: .jewelcrafting) ?? 1
                if showOnlyCraftable && !gameManager.canCraftItem(item) { return false }
                return jewelcraftingLevel >= requiredLevel || (requiredLevel - jewelcraftingLevel <= 5)
            }.sorted { $0.tier < $1.tier }
            
            if filtered.isEmpty { return nil }
            return ItemCraftingSection(title: title, items: filtered)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable)
                    .padding(.horizontal)
                
                List {
                    // --- Render Cut Gemstone Sections ---
                    ForEach(organizedGems) { section in
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
                    
                    // --- Render Ring & Necklace Sections ---
                    ForEach(organizedJewelry) { section in
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
                    
                    // A static info section, as you had before
                    Section(header: Text("Precious Metals")) {
                        Text("Note: Silver, Gold, and Platinum ingots are smelted at the Forge.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(
                Image("jewelcrafting_background") // <-- Use a unique background for this station
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.5)) // Slightly darken for better text contrast
            )
            .navigationTitle("Jewel Crafting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Preview Provider
struct JewelCraftingView_Previews: PreviewProvider {
    class MockJewelGameManager: GameManager {
        override init() {
            super.init()
            // Provide sample data for previewing
            self.playerInventory[.T1_gemstone] = 5
            self.playerInventory[.T2_gemstone] = 3
            self.sanctumComponentStorage[.silverIngot] = 10
            self.activeBaseUpgrades.insert(.jewelCraftingWorkshop)
            self.playerSkillsXP[.jewelcrafting] = 600
            self.updateAllSkillLevelsFromXP()
        }
    }
    static var previews: some View {
        JewelCraftingView(gameManager: MockJewelGameManager())
    }
}
