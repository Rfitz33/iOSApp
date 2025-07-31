//
//  CraftingSection.swift
//  LocationBasedGame
//
//  Created by Reid on 7/28/25.
//


// CraftingUIHelpers.swift
import SwiftUI

// --- 1. CraftingSection Struct ---
// (This was previously inside ForgeActionsView)
struct CraftingSection: Identifiable {
    let id = UUID()
    let title: String
    let components: [ComponentType]
}

// A struct to manage a single piece of "juicy" feedback
struct CraftingFeedback: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var icon: String?
    var count: Int = 1
    var isXP: Bool = false
}

struct CraftingFeedbackView: View {
    let feedback: CraftingFeedback
    
    var body: some View {
        HStack(spacing: 4) {
            // 1. Show the text first. For items, it will be "+(count)". For XP, the full string.
            if feedback.isXP {                Text(feedback.text)
            } else {
                Text("+\(feedback.count)")
            }
            if let icon = feedback.icon {
                Image(icon)
                    .resizable().scaledToFit().frame(width: 16, height: 16)
            }
        }
        .font(feedback.isXP ? .subheadline : .headline)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 5)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
}

// --- 2. IngredientView Struct ---
// (This was also previously inside ForgeActionsView)
struct IngredientView: View {
    let name: String
    let icon: String
    let currentAmount: Int
    let requiredAmount: Int
    
    private var hasEnough: Bool { currentAmount >= requiredAmount }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(icon)
                .resizable().scaledToFit().frame(width: 16, height: 16)
            Text("\(name):")
            Text("\(currentAmount)/\(requiredAmount)")
                .foregroundColor(hasEnough ? .green : .red)
                .fontWeight(.bold)
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}

// --- 3. Reusable Row for Craftable ITEMS ---
struct ItemRecipeRow: View {
    @ObservedObject var gameManager: GameManager
    let item: ItemType
    
    // We need to know which skill to check for level requirements.
    // We can infer this from the recipe's XP grants.
    private var requiredSkill: SkillType {
        // Return the first skill found in the recipe's XP dictionary,
        // or a sensible default like Carpentry.
        return item.recipe?.skillXP?.keys.first ?? .carpentry
    }

    private var isUnlocked: Bool {
        let requiredLevel = item.recipe?.requiredSkillLevel(for: requiredSkill) ?? 1
        return gameManager.getLevel(for: requiredSkill) >= requiredLevel
    }
    
    private var isCraftable: Bool {
        gameManager.canCraftItem(item)
    }
    var onCraft: (ItemType) -> Void

    var body: some View {
        HStack {
            // Item Icon and Name
            Image(item.iconAssetName)
                .resizable().scaledToFit().frame(width: 32, height: 32)
                .padding(4).background(Color.gray.opacity(0.1)).cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(item.displayName).font(.headline)
                
                // Dynamic Ingredient Display
                if let recipe = item.recipe {
                    // This can be expanded into a multi-line view if recipes get complex
                    HStack {
                        // Display standard resource ingredients
                        if let resources = recipe.resources {
                            ForEach(resources.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { resource in
                                IngredientView(name: resource.displayName, icon: resource.inventoryIconAssetName, currentAmount: gameManager.playerInventory[resource, default: 0], requiredAmount: resources[resource, default: 0])
                            }
                        }
                        // Display standard component ingredients
                        if let components = recipe.components {
                            ForEach(components.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { component in
                                IngredientView(name: component.displayName, icon: component.iconAssetName, currentAmount: gameManager.sanctumComponentStorage[component, default: 0], requiredAmount: components[component, default: 0])
                            }
                        }
                    }
                } else {
                    Text("No recipe").font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Spacer()
            VStack {
                Button("Craft") {
                        // When tapped, it performs the craft...
                        if gameManager.craftItem(item) {
                            // ...and then calls the closure to notify the parent.
                            onCraft(item)
                        }
                    }
                    .buttonStyle(.bordered).tint(.green).disabled(!isCraftable)
                    
                    Text("Owned: \(gameManager.sanctumItemStorage[item, default: 0])")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
            .opacity(isUnlocked ? 1.0 : 0.4)
            .overlay(
            ZStack {
                if !isUnlocked {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3))
                    let requiredLevel = item.recipe?.requiredSkillLevel(for: requiredSkill) ?? 0
                    Text("Requires \(requiredSkill.displayName) Level \(requiredLevel)")
                        .font(.caption.bold()).foregroundColor(.white).padding(4)
                        .background(Color.black.opacity(0.6)).cornerRadius(5)
                }
            }
        )
        .allowsHitTesting(isUnlocked)
    }
}

// And we need the corresponding helper on ItemType.Recipe
// In ResourceType.swift (or wherever ItemType is), add this to ItemType.Recipe
extension ItemType.ItemRecipe {
    func requiredSkillLevel(for skill: SkillType) -> Int {
        // Find the tier of the item this recipe belongs to
        guard let itemTier = ItemType.allCases.first(where: { $0.recipe?.requiredUpgrade == self.requiredUpgrade && $0.recipe?.resources == self.resources && $0.recipe?.components == self.components })?.tier else {
            return 1
        }
        
        switch itemTier {
        case 0, 1: return 1
        case 2: return 5
        default: return (itemTier - 1) * 5
        }
    }
}

// --- 4. The Main Reusable ComponentRecipeRow ---
// (This was also in ForgeActionsView)
// We make it more generic by passing in the required skill.
struct ComponentRecipeRow: View {
    @ObservedObject var gameManager: GameManager
    let component: ComponentType
    let requiredSkill: SkillType
    
//    @State private var feedbackItems: [CraftingFeedback] = []
//    @State private var feedbackTimer: Timer? = nil
    
    private var isUnlocked: Bool {
        let requiredLevel = component.requiredSkillLevel(for: requiredSkill)
        return gameManager.getLevel(for: requiredSkill) >= requiredLevel
    }
    
    private var isCraftable: Bool {
        gameManager.canCraftComponent(component)
    }
    var onCraft: (ComponentType) -> Void
    
    var body: some View {
        HStack {
            // Item Icon and Name
            Image(component.iconAssetName)
                .resizable().scaledToFit().frame(width: 32, height: 32)
                .padding(4).background(Color.gray.opacity(0.1)).cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(component.displayName).font(.headline)
                
                // --- Dynamic Ingredient Display (Now with Generic Support) ---
                if let recipe = component.recipe {
                    HStack {
                        // Display standard resource ingredients
                        if let resources = recipe.ingredients {
                            ForEach(resources.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { resource in
                                IngredientView(
                                    name: resource.displayName,
                                    icon: resource.inventoryIconAssetName,
                                    currentAmount: gameManager.playerInventory[resource, default: 0],
                                    requiredAmount: resources[resource, default: 0]
                                )
                            }
                        }
                        // Display standard component ingredients
                        if let components = recipe.components {
                            ForEach(components.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { component in
                                IngredientView(
                                    name: component.displayName,
                                    icon: component.iconAssetName,
                                    currentAmount: gameManager.sanctumComponentStorage[component, default: 0],
                                    requiredAmount: components[component, default: 0]
                                )
                            }
                        }
                        // --- Display GENERIC ingredients ---
                        if let generic = recipe.genericIngredients {
                            ForEach(generic.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { genericType in
                                let (name, icon, current, required) = findBestGenericIngredient(for: genericType)
                                IngredientView(name: name, icon: icon, currentAmount: current, requiredAmount: required)
                            }
                        }
                    }
                } else {
                    Text("No recipe").font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack {
                Button("Craft") {
                    // When tapped, it performs the craft...
                    if gameManager.craftComponent(component) {
                        // ...and then calls the closure to notify the parent.
                        onCraft(component)
                    }
                }
                .buttonStyle(.bordered).tint(.green).disabled(!isCraftable)
                Text("Owned: \(gameManager.sanctumComponentStorage[component, default: 0])")
                    .font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.4)
        .overlay(
            ZStack {
                if !isUnlocked {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3))
                    let requiredLevel = component.requiredSkillLevel(for: requiredSkill)
                    Text("Requires \(requiredSkill.displayName) Level \(requiredLevel)")
                        .font(.caption.bold()).foregroundColor(.white).padding(4)
                        .background(Color.black.opacity(0.6)).cornerRadius(5)
                }
            }
        )
        .allowsHitTesting(isUnlocked)
    }
    
    // --- Helper function for generic ingredients ---
    private func findBestGenericIngredient(for genericType: GenericIngredient) -> (name: String, icon: String, current: Int, required: Int) {
        let requiredAmount = component.recipe?.genericIngredients?[genericType] ?? 1
        
        switch genericType {
        case .anyStandardIngot:
            // Find the lowest-tier ingot the player has enough of
            let bestIngot = ComponentType.allCases
                .filter {
                    $0.displayName.contains("Ingot") && !$0.displayName.contains("Silver") &&
                    !$0.displayName.contains("Gold") && !$0.displayName.contains("Platinum") &&
                    (gameManager.sanctumComponentStorage[$0] ?? 0) >= requiredAmount
                }
                .sorted { $0.tier < $1.tier }
                .first
            
            if let ingot = bestIngot {
                // If they have a suitable ingot, display it
                return (ingot.displayName, ingot.iconAssetName, gameManager.sanctumComponentStorage[ingot, default: 0], requiredAmount)
            } else {
                // If they don't have any, show the generic requirement
                // We can also find the total number of all ingots they have for the 'current' value
                let totalIngots = ComponentType.allCases.reduce(0) { (currentSum, component) -> Int in
                    // Check if the component is a standard ingot
                    if component.displayName.contains("Ingot") &&
                        !component.displayName.contains("Silver") &&
                        !component.displayName.contains("Gold") &&
                        !component.displayName.contains("Platinum") {
                        // If so, add the player's count of that ingot to the sum.
                        return currentSum + (gameManager.sanctumComponentStorage[component, default: 0])
                    }
                    // Otherwise, just return the current sum.
                    return currentSum
                }
                return (genericType.displayName, "T1_ingot", totalIngots, requiredAmount)
            }
        }
    }
}
