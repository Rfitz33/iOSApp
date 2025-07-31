//
//  WoodworkingShopActionsView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/5/25.
//


// WoodworkingShopActionsView.swift
import SwiftUI

struct WoodworkingShopActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    //    @State private var lastCraftedComponent: ComponentType? = nil
    //    @State private var lastCraftedItem: ItemType? = nil
    
    @State private var feedbackItems: [CraftingFeedback] = []
    //    @State private var feedbackAnchor: Anchor<CGPoint>? = nil
    @State private var feedbackTimer: Timer? = nil
    
    // MARK: - Data Preparation
    
    // --- Components Crafted Here ---
    private var organizedComponents: [CraftingSection] {
        let carpentryLevel = gameManager.getLevel(for: .carpentry)
        let sections: [(title: String, components: [ComponentType])] = [
            ("Planks", ComponentType.allCases.filter { $0.category == .carpentry && $0.rawValue.contains("plank") }),
            ("Tool Handles", ComponentType.allCases.filter { $0.category == .carpentry && $0.rawValue.contains("Handle") })
        ]
        
        return sections.compactMap { title, components in
            let filtered = components.filter { component in
                let requiredLevel = component.requiredSkillLevel(for: .carpentry)
                if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
                return carpentryLevel >= requiredLevel || (requiredLevel - carpentryLevel <= 5)
            }.sorted { $0.tier < $1.tier }
            
            if filtered.isEmpty { return nil }
            return CraftingSection(title: title, components: filtered)
        }
    }
    
    // --- Items Assembled Here ---
    private var organizedItems: [ItemCraftingSection] { // Using a new helper struct for items
        let carpentryLevel = gameManager.getLevel(for: .carpentry)
        let sections: [(title: String, items: [ItemType])] = [
            ("Tool Assembly", ItemType.allCases.filter { ($0.toolCategory == .axe || $0.toolCategory == .pickaxe || $0.toolCategory == .knife) && $0.recipe?.requiredUpgrade == .woodworkingShop })
        ]
        
        return sections.compactMap { title, items in
            let filtered = items.filter { item in
                let requiredLevel = item.recipe?.requiredSkillLevel(for: .carpentry) ?? 1
                if showOnlyCraftable && !gameManager.canCraftItem(item) { return false }
                return carpentryLevel >= requiredLevel || (requiredLevel - carpentryLevel <= 5)
            }.sorted { $0.tier < $1.tier }
            
            if filtered.isEmpty { return nil }
            return ItemCraftingSection(title: title, items: filtered)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Show Only Craftable", isOn: $showOnlyCraftable).padding(.horizontal)
                
                // The ZStack provides a canvas for the List and its overlay.
                ZStack {
                    // The List is now its own clean component.
                    craftingList
                    
                    // The overlay for pop-ups is now cleanly separated.
                    feedbackOverlay
                }
            }
            .background(craftingBackground) // The background is its own component.
            .navigationTitle("Woodworking Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
        .navigationViewStyle(.stack)
    }

    // --- NEW: Computed Properties to break up the body ---

    @ViewBuilder
    private var craftingList: some View {
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
                                showCraftingFeedback(forComponent: craftedComponent)
                            }
                        )
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
            // --- Filter the array to only show visible items ---
            ForEach(feedbackItems.filter { $0.isVisible }) { feedback in
                CraftingFeedbackView(feedback: feedback)
            }
        }
        .frame(width: 250, height: 120, alignment: .bottom) // alignment: .bottom makes new items appear from the bottom up
        .offset(y: -UIScreen.main.bounds.height / 5)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var craftingBackground: some View {
        // The background is also isolated.
        Image("woodshop_background").resizable().scaledToFill()
            .edgesIgnoringSafeArea(.all).overlay(Color.black.opacity(0.4))
    }

    
    // --- THE FEEDBACK LOGIC NOW LIVES HERE ---
    private func showCraftingFeedback(forItem item: ItemType) {
        handleFeedback(name: item.displayName, icon: item.iconAssetName, yield: item.craftYield, xp: item.recipe?.skillXP)
    }

    private func showCraftingFeedback(forComponent component: ComponentType) {
        handleFeedback(name: component.displayName, icon: component.iconAssetName, yield: component.craftYield, xp: component.recipe?.skillXP)
    }
    
    // One generic function to handle all feedback
    private func handleFeedback(name: String, icon: String, yield: Int, xp: [SkillType: Int]?) {
        feedbackTimer?.invalidate()
        
        // --- ITEM FEEDBACK ---
        // The text for item feedback is now empty, as the count and icon are separate.
        if let existingIndex = feedbackItems.firstIndex(where: { $0.icon == icon }) {
            feedbackItems[existingIndex].count += yield
            feedbackItems[existingIndex].isVisible = true
        } else {
            // Create the feedback with an empty text string.
            feedbackItems.append(CraftingFeedback(text: "", icon: icon, count: yield))
        }
        
        // --- XP FEEDBACK ---
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
        
        // --- LOGGING ---
        // The log message is now constructed with the correct name.
        let logMessageText = "Crafted \(yield)x \(name)!"
        gameManager.logMessage(logMessageText, type: .success)
        
        // --- NEW Dismissal Logic ---
        let itemsToDismiss = feedbackItems // Make a copy of the current items
        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            for item in itemsToDismiss {
                // Find the corresponding item in the main array and set its visibility to false
                if let index = feedbackItems.firstIndex(where: { $0.id == item.id }) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        feedbackItems[index].isVisible = false
                    }
                }
            }
            // Clean up the array after the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                feedbackItems.removeAll { !$0.isVisible }
            }
        }
    }
}

// Preview for WoodworkingShopActionsView
struct WoodworkingShopActionsView_Previews: PreviewProvider {
    class MockWoodworkingGameManager: GameManager {
        override init() {
            super.init()
            self.playerInventory = [.T1_wood: 10, .T2_wood: 10, .T1_stone: 5]
            self.sanctumComponentStorage = [.T1_plank: 5, .T2_ingot: 4, .T1_leather: 2]
            self.activeBaseUpgrades.insert(.woodworkingShop) // Assume shop is built
            self.activeBaseUpgrades.insert(.basicForge)    // For ingots
        }
    }
    static var previews: some View {
        WoodworkingShopActionsView(gameManager: MockWoodworkingGameManager())
    }
}

//    private func showCraftingFeedback(forComponent component: ComponentType) {
//        // Invalidate any previous timer to allow for aggregation.
//        feedbackTimer?.invalidate()
//
//        // --- Item Feedback ---
//        let itemText = "+"
//        let itemIcon = component.iconAssetName
//        let craftYield = component.craftYield // Use the component's craft yield
//
//        if let existingItemIndex = feedbackItems.firstIndex(where: { $0.icon == itemIcon }) {
//            feedbackItems[existingItemIndex].count += craftYield
//        } else {
//            let newItemFeedback = CraftingFeedback(text: itemText, icon: itemIcon, count: craftYield)
//            feedbackItems.append(newItemFeedback)
//        }
//
//        // --- XP Feedback & LOGGING ---
//        if let xpGrants = component.recipe?.skillXP {
//            for (skill, amount) in xpGrants where amount > 0 {
//                let skillIdentifier = skill.displayName
//                let totalXpForThisCraft = amount * Int(craftYield)
//
//                // Correctly find and update the existing XP notice
//                if let existingXPIndex = feedbackItems.firstIndex(where: { $0.text.contains(skillIdentifier) }) {
//                    let currentTotalXP = feedbackItems[existingXPIndex].count
//                    let newTotalXP = currentTotalXP + totalXpForThisCraft
//                    feedbackItems[existingXPIndex].text = "+\(newTotalXP) \(skillIdentifier) XP"
//                    feedbackItems[existingXPIndex].count = newTotalXP
//                } else {
//                    // No existing notice, create a new one
//                    let newXPFeedback = CraftingFeedback(text: "+\(totalXpForThisCraft) \(skillIdentifier) XP", count: totalXpForThisCraft, isXP: true)
//                    feedbackItems.append(newXPFeedback)
//                }
//            }
//        }
//
//        // Log the craft action once per tap.
//        let logMessageText = "Crafted \(craftYield)x \(component.displayName)!"
//        gameManager.logMessage(logMessageText, type: .success)
//
//        // Schedule a NEW timer to dismiss the pop-ups.
//        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
//            withAnimation {
//                feedbackItems.removeAll()
//            }
//        }
//    }
//
//    private func showCraftingFeedback(forItem item: ItemType) {
//        // Invalidate any previous timer to allow for aggregation.
//        feedbackTimer?.invalidate()
//
//        // --- Item Feedback ---
//        let itemText = "+"
//        let itemIcon = item.iconAssetName
//        let craftYield = item.craftYield // Use the item's craft yield
//
//        if let existingItemIndex = feedbackItems.firstIndex(where: { $0.icon == itemIcon }) {
//            feedbackItems[existingItemIndex].count += craftYield
//        } else {
//            let newItemFeedback = CraftingFeedback(text: itemText, icon: itemIcon, count: craftYield)
//            feedbackItems.append(newItemFeedback)
//        }
//
//        // --- XP Feedback & LOGGING ---
//        if let xpGrants = item.recipe?.skillXP {
//            for (skill, amount) in xpGrants where amount > 0 {
//                let skillIdentifier = skill.displayName
//                let totalXpForThisCraft = amount * Int(craftYield)
//
//                // Correctly find and update the existing XP notice
//                if let existingXPIndex = feedbackItems.firstIndex(where: { $0.text.contains(skillIdentifier) }) {
//                    let currentTotalXP = feedbackItems[existingXPIndex].count
//                    let newTotalXP = currentTotalXP + totalXpForThisCraft
//                    feedbackItems[existingXPIndex].text = "+\(newTotalXP) \(skillIdentifier) XP"
//                    feedbackItems[existingXPIndex].count = newTotalXP
//                } else {
//                    // No existing notice, create a new one
//                    let newXPFeedback = CraftingFeedback(text: "+\(totalXpForThisCraft) \(skillIdentifier) XP", count: totalXpForThisCraft, isXP: true)
//                    feedbackItems.append(newXPFeedback)
//                }
//            }
//        }
//
//        // Log the craft action once per tap.
//        let logMessageText = "Crafted \(craftYield)x \(item.displayName)!"
//        gameManager.logMessage(logMessageText, type: .success)
//
//        // Schedule a NEW timer to dismiss the pop-ups.
//        feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
//            withAnimation {
//                feedbackItems.removeAll()
//            }
//        }
//    }
//}
