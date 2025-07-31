// ApothecaryActionsView.swift
import SwiftUI

struct ApothecaryActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil
    
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil

    // MARK: - Data Preparation
    
    // --- Components Crafted Here (Herbal Preparations) ---
    private var organizedHerbs: [CraftingSection] {
        let herbloreLevel = gameManager.getLevel(for: .herblore)
        let herbComponents = ComponentType.allCases.filter { $0.category == .herblore }
        
        let filtered = herbComponents.filter { component in
            let requiredLevel = component.requiredSkillLevel(for: .herblore)
            if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
            return herbloreLevel >= requiredLevel || (requiredLevel - herbloreLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Herbal Preparations", components: filtered)]
    }
    
    // --- Items Assembled Here (Potions) ---
    private var organizedPotions: [ItemCraftingSection] {
        let herbloreLevel = gameManager.getLevel(for: .herblore)
        let potionItems = ItemType.allCases.filter { $0.potionEffect != nil }
        
        let filtered = potionItems.filter { item in
            let requiredLevel = item.recipe?.requiredSkillLevel(for: .herblore) ?? 1
            if showOnlyCraftable && !gameManager.canCraftItem(item) { return false }
            return herbloreLevel >= requiredLevel || (requiredLevel - herbloreLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [ItemCraftingSection(title: "Potion Brewing", items: filtered)]
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable)
                    .padding(.horizontal)
                
                List {
                    // --- Render Herbal Preparation Sections ---
                    ForEach(organizedHerbs) { section in
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
                    
                    // --- Render Potion Sections ---
                    ForEach(organizedPotions) { section in
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
                Image("apothecary_background") // <-- Use a unique background for this station
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.4)) // Darken for readability
            )
            .navigationTitle("Apothecary Stand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Preview Provider
struct ApothecaryActionsView_Previews: PreviewProvider {
    class MockApothecaryGameManager: GameManager {
        override init() {
            super.init()
            // Provide enough sample data to see the recipes
            self.playerInventory = [.T1_herb: 10, .T2_herb: 10]
            self.sanctumComponentStorage = [.T1_plantComp: 2, .T2_plantComp: 2]
            self.activeBaseUpgrades.insert(.apothecaryStand)
            self.playerSkillsXP[.herblore] = 400 // Set a skill level for the preview
            self.updateAllSkillLevelsFromXP()
        }
    }
    static var previews: some View {
        ApothecaryActionsView(gameManager: MockApothecaryGameManager())
    }
}
