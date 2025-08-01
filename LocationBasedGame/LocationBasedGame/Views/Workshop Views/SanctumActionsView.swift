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
    
    // --- State for the feedback system ---
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil

    // MARK: - Data Preparation (Your existing logic is correct)
    
    private var organizedComponents: [CraftingSection] {
        let tierZeroComponents: [ComponentType] = [
            .T0_axeHandle, .T0_axeHead, .T0_pickaxeH, .T0_knifeHandle, .T0_knifeBlade
        ]
        let filtered = tierZeroComponents.filter { component in
            showOnlyCraftable ? gameManager.canCraftComponent(component) : true
        }.sorted { $0.displayName < $1.displayName } // Sort alphabetically for T0
        
        if filtered.isEmpty { return [] }
        return [CraftingSection(title: "Tool Component Crafting", components: filtered)]
    }
    
    private var organizedItems: [ItemCraftingSection] {
        let tierZeroItems: [ItemType] = [
            .T0_pickaxe, .T0_axe, .T0_huntingKnife
        ]
        let filtered = tierZeroItems.filter { item in
            showOnlyCraftable ? gameManager.canCraftItem(item) : true
        }.sorted { $0.displayName < $1.displayName }
        
        if filtered.isEmpty { return [] }
        return [ItemCraftingSection(title: "Basic Tool Assembly", items: filtered)]
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
            .navigationTitle("Sanctum Workshop")
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
            ForEach(organizedComponents) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.components) { component in
                        ComponentRecipeRow(
                            gameManager: gameManager,
                            component: component,
                            requiredSkill: .carpentry, // Default skill for T0
                            onCraft: { craftedComponent in
                                showCraftingFeedback(forComponent: craftedComponent)
                            }
                        )
                    }
                }
            }
            
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
        Image("sanctum_background")
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
