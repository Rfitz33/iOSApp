import SwiftUI

struct TanningActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var lastCraftedComponent: ComponentType? = nil
    @State private var lastCraftedItem: ItemType? = nil

    // MARK: - Data Preparation
    
    // --- Components Crafted Here (Leather) ---
    private var organizedLeathers: [CraftingSection] {
        let leatherworkingLevel = gameManager.getLevel(for: .leatherworking)
        // We define this station's components in one place.
        let leatherComponents = ComponentType.allCases.filter { $0.category == .leatherworking }
        
        let filtered = leatherComponents.filter { component in
            let requiredLevel = component.requiredSkillLevel(for: .leatherworking)
            if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
            return leatherworkingLevel >= requiredLevel || (requiredLevel - leatherworkingLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        // Return as a single CraftingSection.
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Tanning & Curing", components: filtered)]
    }
    
    // --- Items Assembled Here (Bags & Satchels) ---
    private var organizedBags: [ItemCraftingSection] {
        let leatherworkingLevel = gameManager.getLevel(for: .leatherworking)
        let bagItems = ItemType.allCases.filter {
            $0.equipmentSlot == .backpack || $0.equipmentSlot == .satchel
        }
        
        let filtered = bagItems.filter { item in
            let requiredLevel = item.recipe?.requiredSkillLevel(for: .leatherworking) ?? 1
            if showOnlyCraftable && !gameManager.canCraftItem(item) { return false }
            return leatherworkingLevel >= requiredLevel || (requiredLevel - leatherworkingLevel <= 5)
        }.sorted { $0.tier < $1.tier }
        
        if filtered.isEmpty { return [] }
        return [ItemCraftingSection(title: "Bag & Satchel Assembly", items: filtered)]
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable)
                    .padding(.horizontal)
                
                List {
                    // --- Render Leather Component Sections ---
                    ForEach(organizedLeathers) { section in
                        Section(header: Text(section.title)) {
                            ForEach(section.components) { component in
                                ComponentRecipeRow(
                                    gameManager: gameManager,
                                    component: component,
                                    requiredSkill: .leatherworking,
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
                    
                    // --- Render Bag Item Sections ---
                    ForEach(organizedBags) { section in
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
                Image("tanning_rack_background") // <-- Use a unique background for this station
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3)) // Darken for readability
            )
            .navigationTitle("Tanning Rack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Preview Provider
struct TanningActionsView_Previews: PreviewProvider {
    class MockTanningGameManager: GameManager {
        override init() {
            super.init()
            self.playerInventory = [.T1_hide: 10, .T2_hide: 1]
            self.sanctumComponentStorage = [.T1_leather: 3, .buckle: 5]
            self.activeBaseUpgrades.insert(.tanningRack)
            self.playerSkillsXP[.leatherworking] = 300 // Set a skill level for the preview
            self.updateAllSkillLevelsFromXP()
        }
    }
    static var previews: some View {
        TanningActionsView(gameManager: MockTanningGameManager())
    }
}
