//
//  GameManager+Inventory.swift
//  LocationBasedGame
//
//  Created by Reid on 6/19/25.
//

import Foundation

// MARK: - Saving Logic
extension GameManager {
    
    // --- Capacity Bonus Properties (for UI display) ---
        
        // Returns the capacity bonus provided by the BEST equipped backpack.
        var currentBackpackBonus: Int {
            if (sanctumItemStorage[.T6_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            if (sanctumItemStorage[.T5_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            if (sanctumItemStorage[.T4_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            if (sanctumItemStorage[.T3_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            if (sanctumItemStorage[.T2_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            if (sanctumItemStorage[.T1_backpack] ?? 0) > 0 { return ItemType.T2_backpack.generalResourceCapacityBonus }
            return 0
        }
        
        // Returns the capacity bonus provided by the BEST equipped satchel.
        var currentSatchelBonus: Int {
            if (sanctumItemStorage[.T5_herbSatchel] ?? 0) > 0 { return ItemType.T1_herbSatchel.herbCapacityBonus }
            if (sanctumItemStorage[.T4_herbSatchel] ?? 0) > 0 { return ItemType.T1_herbSatchel.herbCapacityBonus }
            if (sanctumItemStorage[.T3_herbSatchel] ?? 0) > 0 { return ItemType.T1_herbSatchel.herbCapacityBonus }
            if (sanctumItemStorage[.T2_herbSatchel] ?? 0) > 0 { return ItemType.T1_herbSatchel.herbCapacityBonus }
            if (sanctumItemStorage[.T1_herbSatchel] ?? 0) > 0 { return ItemType.T1_herbSatchel.herbCapacityBonus }
            return 0
        }
        
        // Returns the capacity bonus provided by the Storehouse upgrade.
        var storehouseBonus: Int {
            // This value could be stored with the UpgradeDefinition later. For now, it's hardcoded.
            return activeBaseUpgrades.contains(.basicStorehouse) ? 150 : 0
        }
    
    func dropResource(resourceType: ResourceType, amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let currentAmount = playerInventory[resourceType] ?? 0
        guard currentAmount >= amount else {
            print("Cannot drop \(amount) of \(resourceType.displayName), only have \(currentAmount).")
            // Optionally, only drop what they have: actualAmountToDrop = currentAmount
            return false
        }
        
        playerInventory[resourceType] = currentAmount - amount
        if playerInventory[resourceType] == 0 {
            playerInventory.removeValue(forKey: resourceType) // Clean up
        }
        print("Dropped \(amount) of \(resourceType.displayName).")
        // updateTotalResourceLoads() will be called by playerInventory.didSet
        return true
    }

    func dropComponent(componentType: ComponentType, amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let currentAmount = sanctumComponentStorage[componentType] ?? 0
        guard currentAmount >= amount else { return false }
        
        sanctumComponentStorage[componentType] = currentAmount - amount
        if sanctumComponentStorage[componentType] == 0 {
            sanctumComponentStorage.removeValue(forKey: componentType)
        }
        print("Dropped \(amount) of \(componentType.displayName).")
        return true
    }

    func dropItem(itemType: ItemType, amount: Int) -> Bool {
        guard amount > 0 else { return false }
        let currentAmount = sanctumItemStorage[itemType] ?? 0
        guard currentAmount >= amount else { return false }

        sanctumItemStorage[itemType] = currentAmount - amount
        if sanctumItemStorage[itemType] == 0 {
            sanctumItemStorage.removeValue(forKey: itemType)
            // If the dropped item was a tool with durability, clear its durability entry
            if itemType.maxDurability != nil {
                currentToolDurability.removeValue(forKey: itemType)
                print("Cleared durability for dropped \(itemType.displayName).")
            }
        }
        print("Dropped \(amount) of \(itemType.displayName).")
        // updateTotalResourceLoads() will be called by sanctumItemStorage.didSet if bags are involved
        return true
    }
    
    func clearPetsForTesting() {
        print("--- Clearing all pet data for testing ---")
        
        // Reset the in-memory properties
        self.ownedCreatures = []
        self.incubatingSlots = []
        self.activeCreatureID = nil
        self.petGrowthReductions = [:]
        self.unlockedPetTypes = []
        
        // IMPORTANT: Save the empty states to clear the data in UserDefaults
        saveCreaturesState()
        saveIncubationState()
        saveUnlockedPetTypes()
        
        print("Pet data cleared and saved.")
    }
}
