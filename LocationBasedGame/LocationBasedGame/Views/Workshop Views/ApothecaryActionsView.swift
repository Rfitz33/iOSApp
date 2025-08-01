// ApothecaryActionsView.swift
import SwiftUI

struct ApothecaryActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    
    // --- State for the feedback system ---
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil

    // MARK: - Data Preparation (Your existing logic is correct)
    
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

    // --- NEW, ROBUST BODY ---
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable).padding(.horizontal)
                
                ZStack {
                    craftingList
                    feedbackOverlay
                }
            }
            .background(craftingBackground)
            .navigationTitle("Apothecary Stand")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }

    // --- COMPUTED PROPERTIES FOR THE BODY ---

    @ViewBuilder
    private var craftingList: some View {
        List {
            ForEach(organizedHerbs) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.components) { component in
                        ComponentRecipeRow(
                            gameManager: gameManager,
                            component: component,
                            requiredSkill: .herblore, // Use the correct skill
                            onCraft: { craftedComponent in
                                showCraftingFeedback(forComponent: craftedComponent)
                            }
                        )
                    }
                }
            }
            
            ForEach(organizedPotions) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.items) { item in
                        ItemRecipeRow(
                            gameManager: gameManager,
                            item: item,
                            onCraft: { craftedItem in
                                showCraftingFeedback(forItem: craftedItem)
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var feedbackOverlay: some View {
        VStack(spacing: 4) {
            ForEach(feedbackItems.filter { $0.isVisible }) { feedback in
                CraftingFeedbackView(feedback: feedback)
            }
        }
        .frame(width: 250, height: 120, alignment: .bottom)
        .offset(y: -UIScreen.main.bounds.height / 5)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var craftingBackground: some View {
        Image("apothecary_background")
            .resizable().scaledToFill()
            .edgesIgnoringSafeArea(.all).overlay(Color.black.opacity(0.4))
    }
    
    // --- FEEDBACK LOGIC FUNCTIONS ---
    
    private func showCraftingFeedback(forItem item: ItemType) {
        handleFeedback(name: item.displayName, icon: item.iconAssetName, yield: item.craftYield, xp: item.recipe?.skillXP)
    }
    
    private func showCraftingFeedback(forComponent component: ComponentType) {
        handleFeedback(name: component.displayName, icon: component.iconAssetName, yield: component.craftYield, xp: component.recipe?.skillXP)
    }
    
    private func handleFeedback(name: String, icon: String, yield: Int, xp: [SkillType: Int]?) {
        feedbackTimer?.invalidate()

        if let existingIndex = feedbackItems.firstIndex(where: { $0.icon == icon }) {
            feedbackItems[existingIndex].count += yield
            feedbackItems[existingIndex].isVisible = true
        } else {
            feedbackItems.append(CraftingFeedback(text: "", icon: icon, count: yield))
        }
        
        if let xpGrants = xp {
            for (skill, amount) in xpGrants where amount > 0 {
                let totalAmount = amount * Int(yield)
                let skillId = skill.displayName
                if let existingIndex = feedbackItems.firstIndex(where: { $0.text.contains(skillId) }) {
                    let newTotal = feedbackItems[existingIndex].count + totalAmount
                    feedbackItems[existingIndex].text = "+\(newTotal) \(skillId) XP"
                    feedbackItems[existingIndex].count = newTotal
                } else {
                    feedbackItems.append(CraftingFeedback(text: "+\(totalAmount) \(skillId) XP", count: totalAmount, isXP: true))
                }
            }
        }
        
        let logMessageText = "Crafted \(yield)x \(name)!"
        gameManager.logMessage(logMessageText, type: .success)
        
        let itemsToDismiss = feedbackItems
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            for item in itemsToDismiss {
                if let index = feedbackItems.firstIndex(where: { $0.id == item.id }) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        feedbackItems[index].isVisible = false
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                feedbackItems.removeAll { !$0.isVisible }
            }
        }
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
