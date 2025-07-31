//
//  ForgeActionsView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/5/25.
//

import SwiftUI

struct ForgeActionsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var showOnlyCraftable = false
    @State private var feedbackItems: [CraftingFeedback] = []
    @State private var feedbackTimer: Timer? = nil

    // --- DATA PREPARATION ---
    // This computed property does all the hard work of organizing the data.
    private var organizedRecipes: [CraftingSection] {
        let smithingLevel = gameManager.getLevel(for: .smithing) // Get the player's current skill level

        let sections: [(title: String, components: [ComponentType])] = [
            ("Ingots", ComponentType.allCases.filter { $0.displayName.contains("Ingot") }),
            ("Pickaxe Heads", ComponentType.allCases.filter { $0.displayName.contains("Pickaxe Head") }),
            ("Axe Heads", ComponentType.allCases.filter { $0.displayName.contains("Axe Head") }),
            ("Knife Blades", ComponentType.allCases.filter { $0.displayName.contains("Knife Blade") }),
            ("Arrowheads", ComponentType.allCases.filter { $0.displayName.contains("Arrowhead") }),
            ("Misc", [.buckle])
        ]
        
        return sections.compactMap { title, components in
            let filteredComponents = components.filter { component in
                let requiredLevel = component.requiredSkillLevel(for: .smithing)
                if showOnlyCraftable && !gameManager.canCraftComponent(component) { return false }
                return smithingLevel >= requiredLevel || (requiredLevel - smithingLevel <= 5)
            }.sorted { $0.tier < $1.tier }
            
            if filteredComponents.isEmpty { return nil }
            return CraftingSection(title: title, components: filteredComponents)
        }
    }

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
                .navigationTitle("Forge Operations")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
                }
            }
            .navigationViewStyle(.stack)
        }
    
    @ViewBuilder
        private var craftingList: some View {
            List {
                ForEach(organizedRecipes) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.components) { component in
                            ComponentRecipeRow(
                                gameManager: gameManager,
                                component: component,
                                requiredSkill: .smithing, // Use the correct skill
                                onCraft: { craftedComponent in
                                    // Call the feedback function
                                    showCraftingFeedback(forComponent: craftedComponent)
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
       private var craftingBackground: some View {
           // This is identical, just change the image name
           Image("forge_background").resizable().scaledToFill()
               .edgesIgnoringSafeArea(.all).overlay(Color.black.opacity(0.4))
       }
       
       
       private func showCraftingFeedback(forComponent component: ComponentType) {
           handleFeedback(name: component.displayName, icon: component.iconAssetName, yield: component.craftYield, xp: component.recipe?.skillXP)
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


//// --- NEW HELPER VIEW for the recipe row ---
//struct ComponentRecipeRow: View {
//    @ObservedObject var gameManager: GameManager
//    let component: ComponentType
//    
//    // Check if the player has the skill level to see/craft this item
//    private var isUnlocked: Bool {
//        let requiredLevel = component.requiredSkillLevel(for: .smithing)
//        return gameManager.getLevel(for: .smithing) >= requiredLevel
//    }
//    
//    private var isCraftable: Bool {
//        gameManager.canCraftComponent(component)
//    }
//
//    var body: some View {
//        HStack {
//            // Item Icon and Name
//            Image(component.iconAssetName)
//                .resizable().scaledToFit().frame(width: 32, height: 32)
//                .padding(4).background(Color.gray.opacity(0.1)).cornerRadius(8)
//            
//            VStack(alignment: .leading) {
//                Text(component.displayName)
//                    .font(.headline)
//                
//                // --- MODIFIED: Dynamic Ingredient Display ---
//                if let recipe = component.recipe {
//                    HStack {
//                        if let resources = recipe.ingredients {
//                            ForEach(resources.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { resource in
//                                IngredientView(
//                                    name: resource.displayName,
//                                    icon: resource.inventoryIconAssetName,
//                                    currentAmount: gameManager.playerInventory[resource, default: 0],
//                                    requiredAmount: resources[resource, default: 0]
//                                )
//                            }
//                        }
//                        if let components = recipe.components {
//                            ForEach(components.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { component in
//                                IngredientView(
//                                    name: component.displayName,
//                                    icon: component.iconAssetName,
//                                    currentAmount: gameManager.sanctumComponentStorage[component, default: 0],
//                                    requiredAmount: components[component, default: 0]
//                                )
//                            }
//                        }
//                        
//                        // --- Display GENERIC ingredients ---
//                        if let generic = recipe.genericIngredients {
//                            ForEach(generic.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { genericType in
//                                // Find the best available ingredient to display to the player
//                                let (bestName, bestIcon, current, required) = findBestGenericIngredient(for: genericType)
//                                IngredientView(name: bestName, icon: bestIcon, currentAmount: current, requiredAmount: required)
//                            }
//                        }
//                    }
//                } else {
//                    Text("No recipe").font(.caption2).foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//            
//            // Crafting Button
//            VStack {
//                Button("Craft") {
//                    _ = gameManager.craftComponent(component)
//                }
//                .buttonStyle(.bordered)
//                .tint(.green)
//                .disabled(!isCraftable)
//                
//                Text("Owned: \(gameManager.sanctumComponentStorage[component, default: 0])")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding(.vertical, 4)
//        // --- MODIFIED: Apply effects for locked recipes ---
//        .opacity(isUnlocked ? 1.0 : 0.4) // Fade out locked recipes
//        .overlay(
//            // Show an overlay with the unlock requirement if not unlocked
//            ZStack {
//                if !isUnlocked {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.black.opacity(0.3)) // Darken the row
//                    
//                    let requiredLevel = component.requiredSkillLevel(for: .smithing)
//                    Text("Requires Smithing Level \(requiredLevel)")
//                        .font(.caption.bold())
//                        .foregroundColor(.white)
//                        .padding(4)
//                        .background(Color.black.opacity(0.6))
//                        .cornerRadius(5)
//                }
//            }
//        )
//        // Prevent interaction with locked recipes
//        .allowsHitTesting(isUnlocked)
//    }
    
//    private func findBestGenericIngredient(for genericType: GenericIngredient) -> (name: String, icon: String, current: Int, required: Int) {
//       let requiredAmount = component.recipe?.genericIngredients?[genericType] ?? 1
//
//       switch genericType {
//       case .anyStandardIngot:
//           // Find the lowest-tier ingot the player has enough of
//           let bestIngot = ComponentType.allCases
//               .filter {
//                   $0.displayName.contains("Ingot") && !$0.displayName.contains("Silver") &&
//                   !$0.displayName.contains("Gold") && !$0.displayName.contains("Platinum") &&
//                   (gameManager.sanctumComponentStorage[$0] ?? 0) >= requiredAmount
//               }
//               .sorted { $0.tier < $1.tier }
//               .first
//
//           if let ingot = bestIngot {
//               // If they have a suitable ingot, display it
//               return (ingot.displayName, ingot.iconAssetName, gameManager.sanctumComponentStorage[ingot, default: 0], requiredAmount)
//           } else {
//               // If they don't have any, show the generic requirement
//               return (genericType.displayName, "T1_ingot", 0, requiredAmount) // Using T1 ingot icon as placeholder
//           }
//       }
//    }
//}
//
//struct IngredientView: View {
//    let name: String
//    let icon: String // Asset name
//    let currentAmount: Int
//    let requiredAmount: Int
//    
//    private var hasEnough: Bool {
//        currentAmount >= requiredAmount
//    }
//    
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(icon)
//                .resizable().scaledToFit().frame(width: 16, height: 16)
//            Text("\(name):")
//            Text("\(currentAmount)/\(requiredAmount)")
//                .foregroundColor(hasEnough ? .green : .red)
//                .fontWeight(.bold)
//        }
//        .font(.caption)
//        .foregroundColor(.secondary)
//    }
//}

//// --- NEW HELPER EXTENSION to format ingredient strings ---
//extension ComponentType.Recipe {
//    func ingredientsString() -> String {
//        var parts: [String] = []
//        
//        ingredients?.forEach { resource, amount in
//            parts.append("\(amount)x \(resource.displayName)")
//        }
//        components?.forEach { component, amount in
//            parts.append("\(amount)x \(component.displayName)")
//        }
//        
//        return parts.joined(separator: ", ")
//    }
//}
