//
//  GameManager+Crafting.swift
//  LocationBasedGame
//
//  Created by Reid on 6/12/25.
//

import Foundation // Always good to have

// MARK: - Crafting Logic
extension GameManager {
    // All crafting methods will go inside this block.
    
    func canCraftItem(_ itemType: ItemType) -> Bool {
        guard let recipe = itemType.recipe else { return false } // No recipe defined
        if let requiredUpgrade = recipe.requiredUpgrade, !activeBaseUpgrades.contains(requiredUpgrade) {
                    print("Cannot craft \(itemType.displayName): Requires \(requiredUpgrade.displayName).")
                    return false
                }

        // Check resource ingredients
        if let resourceIngredients = recipe.resources {
            for (resource, requiredAmount) in resourceIngredients {
                if (playerInventory[resource] ?? 0) < requiredAmount {
                    return false // Not enough of this resource
                }
            }
        }
        // Check component ingredients
        if let componentIngredients = recipe.components {
            for (component, requiredAmount) in componentIngredients {
                if (sanctumComponentStorage[component] ?? 0) < requiredAmount {
                    return false // Not enough of this component
                }
            }
        }
        // Check item ingredients
        if let itemIngredients = recipe.items {
            for (item, requiredAmount) in itemIngredients {
                if (sanctumItemStorage[item] ?? 0) < requiredAmount {
                    print("Cannot craft \(itemType.displayName): Missing required item \(item.displayName) x\(requiredAmount)")
                    return false
                }
            }
        }
        return true // All ingredients available
    }

    func craftItem(_ itemType: ItemType) -> Bool {
        guard let recipe = itemType.recipe, canCraftItem(itemType) else {
            print("Cannot craft \(itemType.displayName): Missing ingredients, requirements, or no recipe.")
            return false
        }
        
        // --- 1. Material Efficiency Bonus (Storehouse) ---
        let efficiencyBonus = activeBaseUpgrades.contains(.basicStorehouse) ? 0.02 : 0.0
        var savedIngredientMessage: String? = nil
        var efficiencyProcUsed = false // Ensure the bonus only triggers once per craft

        // --- 2. Deduct Ingredients (with a chance to save) ---
        
        // Deduct RESOURCE ingredients
        if let resourceIngredients = recipe.resources {
            for (resource, requiredAmount) in resourceIngredients {
                if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                    savedIngredientMessage = "Saved \(requiredAmount)x \(resource.displayName)!"
                    efficiencyProcUsed = true
                } else {
                    playerInventory[resource, default: 0] -= requiredAmount
                }
            }
        }
        
        // Deduct COMPONENT ingredients
        if let componentIngredients = recipe.components {
            for (component, requiredAmount) in componentIngredients {
                if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                    savedIngredientMessage = "Saved \(requiredAmount)x \(component.displayName)!"
                    efficiencyProcUsed = true
                } else {
                    sanctumComponentStorage[component, default: 0] -= requiredAmount
                }
            }
        }
        
        // Deduct ITEM ingredients (e.g., for bag upgrades)
        if let itemIngredients = recipe.items {
            for (item, requiredAmount) in itemIngredients {
                if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                    savedIngredientMessage = "Saved \(requiredAmount)x \(item.displayName)!"
                    efficiencyProcUsed = true
                } else {
                    sanctumItemStorage[item, default: 0] -= requiredAmount
                }
            }
        }

        // --- 3. Add Crafted Item & Handle Special Logic ---
        
        // Auto-Upgrade/Replace Logic for Bags
        if let upgradedBag = itemType.upgradesBagType {
            if (sanctumItemStorage[upgradedBag] ?? 0) > 0 {
                sanctumItemStorage.removeValue(forKey: upgradedBag)
                print("Replaced \(upgradedBag.displayName) with \(itemType.displayName).")
            }
        }
        
        let amountToCraft = itemType.craftYield
        sanctumItemStorage[itemType, default: 0] += amountToCraft

        // --- 4. Construct Feedback & Grant XP ---
//        var craftedMessage = "Successfully crafted \(amountToCraft)x \(itemType.displayName)!"
        if let maxDura = itemType.maxDurability, (currentToolDurability[itemType] ?? 0) <= 0 {
            currentToolDurability[itemType] = maxDura
//            craftedMessage += " Activated with \(maxDura) durability."
        }
        
        if let xpGrants = recipe.skillXP {
            var xpMessages: [String] = []
            for (skill, amount) in xpGrants where amount > 0 {
                addXP(amount, to: skill)
                xpMessages.append("\(amount) \(skill.displayName) XP")
            }
//            if !xpMessages.isEmpty {
//                craftedMessage += " Gained \(xpMessages.joined(separator: ", "))!"
//            }
        }
        
//        logMessage(craftedMessage, type: .success)
//        feedbackPublisher.send(FeedbackEvent(message: craftedMessage, isPositive: true))
        
        // --- 5. Handle Bonus Feedback (Material Efficiency) ---
        if let savedMessage = savedIngredientMessage {
            logMessage(savedMessage, type: .rare)
            feedbackPublisher.send(FeedbackEvent(message: savedMessage, isPositive: true))
        }

        // --- 6. Handle Quest Progress ---
        if itemType.tier >= 10 {
            let category = itemType.toolCategory
            if category == .axe || category == .pickaxe || category == .knife || category == .bow {
                // Use the return value to resolve the compiler warning.
                _ = updateActivePetQuestProgress(objectiveKey: "t10_plus_crafts")
            }
        }

        return true
    }
    
    func repairTool(tool: ItemType, repairItem: ItemType) -> Bool {
        guard let repairAmount = repairItem.repairAmount, // Is the item a repair item?
              tool.maxDurability != nil, // Is the target a tool?
              (sanctumItemStorage[repairItem] ?? 0) > 0 else { // Do we have the repair item?
            return false
        }

        // Check if tool needs repair
        let maxDura = tool.maxDurability ?? 0
        let currentDura = currentToolDurability[tool] ?? maxDura
        guard currentDura < maxDura else { return false } // Tool already at max durability

        // Consume repair item and add durability
        sanctumItemStorage[repairItem, default: 0] -= 1
        currentToolDurability[tool, default: 0] += repairAmount
        
        // Clamp to max durability
        if (currentToolDurability[tool] ?? 0) > maxDura {
            currentToolDurability[tool] = maxDura
        }
        
        // Add durability
        let oldDurability = currentDura
        var newDurability = oldDurability + repairAmount
        if newDurability > maxDura { newDurability = maxDura }
        currentToolDurability[tool] = newDurability
        let durabilityRestored = newDurability - oldDurability
        
        print("Repaired \(tool.displayName) by \(repairAmount) durability.")
        let xpGained = (tool.tier * tool.tier) * 5 + 5 // e.g., T0=5xp, T1=10xp, T2=25xp, T3=50xp
            addXP(xpGained, to: .smithing) // Grant XP to the Smithing skill
        
        let feedbackMessage = "Repaired \(tool.displayName) by \(durabilityRestored) points. Gained \(xpGained) Smithing XP."
            print(feedbackMessage)
            lastPotionStatusMessage = "Repaired \(tool.displayName)!"
        return true
    }
    
    func canCraftComponent(_ componentType: ComponentType) -> Bool {
        guard let recipe = componentType.recipe else { return false }
        if let requiredUpgrade = recipe.requiredUpgrade, !activeBaseUpgrades.contains(requiredUpgrade) {
            return false
        }

        // Check standard resource ingredients
        if let ingredientResources = recipe.ingredients {
            for (resource, requiredAmount) in ingredientResources {
                if (playerInventory[resource] ?? 0) < requiredAmount { return false }
            }
        }
        // Check standard component ingredients
        if let ingredientComponents = recipe.components {
            for (component, requiredAmount) in ingredientComponents {
                if (sanctumComponentStorage[component] ?? 0) < requiredAmount { return false }
            }
        }
        
        // --- Check for GENERIC ingredients ---
        if let genericIngredients = recipe.genericIngredients {
            for (genericType, requiredAmount) in genericIngredients {
                switch genericType {
                case .anyStandardIngot:
                    // Check if the player has ANY standard ingot.
                    let hasAnyIngot = ComponentType.allCases.contains { component in
                        component.displayName.contains("Ingot") &&
                        !component.displayName.contains("Silver") && // Exclude precious metals
                        !component.displayName.contains("Gold") &&
                        !component.displayName.contains("Platinum") &&
                        (sanctumComponentStorage[component] ?? 0) >= requiredAmount
                    }
                    if !hasAnyIngot { return false } // If no suitable ingot is found, crafting fails.
                }
            }
        }
        
        return true
    }

    func craftComponent(_ componentType: ComponentType) -> Bool {
        guard let recipe = componentType.recipe, canCraftComponent(componentType) else {
            print("Pre-crafting check failed for \(componentType.displayName).")
            return false
        }
        
        // --- 1. Material Efficiency Bonus (Storehouse) ---
        let efficiencyBonus = activeBaseUpgrades.contains(.basicStorehouse) ? 0.02 : 0.0
        var savedIngredientMessage: String? = nil
        var efficiencyProcUsed = false // Ensure the bonus only triggers once per craft

        // --- 2. Deduct Ingredients (with a chance to save) ---
        if let genericIngredients = recipe.genericIngredients {
            for (genericType, requiredAmount) in genericIngredients {
                switch genericType {
                case .anyStandardIngot:
                    // Find the BEST ingot to use (the lowest tier available).
                    let availableIngots = ComponentType.allCases
                        .filter {
                            $0.displayName.contains("Ingot") &&
                            !$0.displayName.contains("Silver") &&
                            !$0.displayName.contains("Gold") &&
                            !$0.displayName.contains("Platinum") &&
                            (sanctumComponentStorage[$0] ?? 0) >= requiredAmount
                        }
                        .sorted { $0.tier < $1.tier } // Sort by tier, lowest first
                    
                    // Consume from the lowest-tier stack we found.
                    if let ingotToConsume = availableIngots.first {
                        if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                            savedIngredientMessage = "Saved \(requiredAmount)x \(ingotToConsume.displayName)!"
                            efficiencyProcUsed = true
                        } else {
                            sanctumComponentStorage[ingotToConsume, default: 0] -= requiredAmount
                        }
                    } else { return false }
                }
            }
        }

        // Deduct RESOURCE ingredients
       if let resourceIngredients = recipe.ingredients {
           for (resource, requiredAmount) in resourceIngredients {
               if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                   savedIngredientMessage = "Saved \(requiredAmount)x \(resource.displayName)!"
                   efficiencyProcUsed = true
               } else {
                   playerInventory[resource, default: 0] -= requiredAmount
               }
           }
       }
       
       // Deduct COMPONENT ingredients
       if let componentIngredients = recipe.components {
           for (component, requiredAmount) in componentIngredients {
               if !efficiencyProcUsed && Double.random(in: 0...1) < efficiencyBonus {
                   savedIngredientMessage = "Saved \(requiredAmount)x \(component.displayName)!"
                   efficiencyProcUsed = true
               } else {
                   sanctumComponentStorage[component, default: 0] -= requiredAmount
               }
           }
       }
       
       // --- 3. Add Crafted Component & Grant XP ---
        let amountToCraft = componentType.craftYield
        sanctumComponentStorage[componentType, default: 0] += amountToCraft
        
//        var feedbackMessage = "Successfully crafted \(amountToCraft) \(componentType.displayName)."
        
        // <<< GRANT SKILL XP FOR COMPONENT CRAFTING (FROM DICTIONARY) >>>
        if let xpGrants = recipe.skillXP {
            var xpMessages: [String] = []
            for (skill, amount) in xpGrants where amount > 0 {
                addXP(amount, to: skill)
                xpMessages.append("\(amount) \(skill.displayName) XP")
            }
//            if !xpMessages.isEmpty {
//                feedbackMessage += " Gained \(xpMessages.joined(separator: ", "))!"
//            }
        }
//        logMessage(feedbackMessage, type: .success)
//        feedbackPublisher.send(FeedbackEvent(message: feedbackMessage, isPositive: true))
        
        // --- 4. Handle Bonus Feedback (Material Efficiency) ---
        if let savedMessage = savedIngredientMessage {
            logMessage(savedMessage, type: .rare)
            feedbackPublisher.send(FeedbackEvent(message: savedMessage, isPositive: true))
        }
        
        // --- 5. Handle Quest Progress ---
        if componentType.tier >= 6 && componentType.displayName.contains("Ingot") {
            let amountSmelted = componentType.craftYield
            // We call the function but ignore the return value with '_ ='.
            // This tells the compiler we are intentionally not using the result.
            _ = updateActivePetQuestProgress(objectiveKey: "t6_plus_ingots", amount: amountSmelted)
        }
        
        return true
    }
}
