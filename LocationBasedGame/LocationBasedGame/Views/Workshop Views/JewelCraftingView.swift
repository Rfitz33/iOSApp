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
    
    // --- State for the feedback system ---
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil

    // MARK: - Data Preparation (Your existing logic is correct)
    
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
    
    private var organizedJewelry: [ItemCraftingSection] {
        let jewelcraftingLevel = gameManager.getLevel(for: .jewelcrafting)
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
            .navigationTitle("Jewel Crafting")
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
            ForEach(organizedGems) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.components) { component in
                        ComponentRecipeRow(
                            gameManager: gameManager,
                            component: component,
                            requiredSkill: .jewelcrafting, // Use the correct skill
                            onCraft: { craftedComponent in
                                showCraftingFeedback(forComponent: craftedComponent)
                            }
                        )
                    }
                }
            }
            
            ForEach(organizedJewelry) { section in
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

            Section(header: Text("Precious Metals")) {
                Text("Note: Silver, Gold, and Platinum ingots are smelted at the Forge.")
                    .font(.caption).foregroundColor(.secondary)
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
        Image("jewelcrafting_background")
            .resizable().scaledToFill()
            .edgesIgnoringSafeArea(.all).overlay(Color.black.opacity(0.5))
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
