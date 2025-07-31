//
//  AlchemyLabView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

// AlchemyLabActionsView.swift
import SwiftUI

struct AlchemyLabActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil

    // MARK: - Data Preparation
    private var organizedRecipes: [CraftingSection] {
        let alchemyLevel = gameManager.getLevel(for: .alchemy)
        let alchemyComponents = ComponentType.allCases.filter { $0.category == .alchemy }
        
        let filtered = alchemyComponents.filter { component in
            let requiredLevel = component.requiredSkillLevel(for: .alchemy)
            if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
            return alchemyLevel >= requiredLevel || (requiredLevel - alchemyLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Material Transmutation", components: filtered)]
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable)
                    .padding(.horizontal)
                
                List(organizedRecipes) { section in
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
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .background(
                Image("alchemy_lab_background") // <-- Use a unique background for this station
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.5)) // Darken for readability
            )
            .navigationTitle("Alchemical Operations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Preview Provider
struct AlchemyLabActionsView_Previews: PreviewProvider {
    class MockAlchemyGameManager: GameManager {
        override init() {
            super.init()
            self.playerInventory[.T2_stone] = 20
            self.playerInventory[.T2_wood] = 5
            self.activeBaseUpgrades.insert(.alchemyLab)
            self.playerSkillsXP[.alchemy] = 100
            self.updateAllSkillLevelsFromXP()
        }
    }
    static var previews: some View {
        AlchemyLabActionsView(gameManager: MockAlchemyGameManager())
    }
}
