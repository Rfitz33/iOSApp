//
//  FletchingView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//
// FletchingView.swift
import SwiftUI

struct FletchingView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil
    
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil

    // MARK: - Data Preparation
    
    // --- Components Crafted Here (Unstrung Bows) ---
    private var organizedBows: [CraftingSection] {
        let fletchingLevel = gameManager.getLevel(for: .fletching)
        let unstrungBows = ComponentType.allCases.filter { $0.category == .fletching && $0.rawValue.contains("uBow") }
        
        let filtered = unstrungBows.filter { component in
            let requiredLevel = component.requiredSkillLevel(for: .fletching)
            if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
            return fletchingLevel >= requiredLevel || (requiredLevel - fletchingLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Bow Carving", components: filtered)]
    }
    
    // --- Items Assembled Here (Bows & Arrows) ---
    private var organizedItems: [ItemCraftingSection] {
        let fletchingLevel = gameManager.getLevel(for: .fletching)
        
        // Define the sections and the items that belong to them
        let sections: [(title: String, items: [ItemType])] = [
            ("Finished Bows", ItemType.allCases.filter { $0.toolCategory == .bow }),
            ("Arrows", ItemType.allCases.filter { $0.toolCategory == .arrows })
        ]
        
        return sections.compactMap { title, items in
            let filtered = items.filter { item in
                let requiredLevel = item.recipe?.requiredSkillLevel(for: .fletching) ?? 1
                if showOnlyCraftable && !gameManager.canCraftItem(item) { return false }
                return fletchingLevel >= requiredLevel || (requiredLevel - fletchingLevel <= 5)
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
                    // --- Render Unstrung Bow Sections ---
                    ForEach(organizedBows) { section in
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
                    
                    // --- Render Bow & Arrow Sections ---
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
                Image("fletching_background") // <-- Use a unique background for this station
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.4))
            )
            .navigationTitle("Fletching Workshop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Preview Provider
struct FletchingView_Previews: PreviewProvider {
    class MockFletchingGameManager: GameManager {
        override init() {
            super.init()
            // Provide sample data for previewing
            self.playerInventory = [.feathers: 50]
            self.sanctumComponentStorage = [.T1_plank: 10, .T1_aHead: 20, .T1_uBow: 1, .T1_leather: 1]
            self.activeBaseUpgrades.insert(.fletchingWorkshop)
            self.playerSkillsXP[.fletching] = 500
            self.updateAllSkillLevelsFromXP()
        }
    }
    static var previews: some View {
        FletchingView(gameManager: MockFletchingGameManager())
    }
}
