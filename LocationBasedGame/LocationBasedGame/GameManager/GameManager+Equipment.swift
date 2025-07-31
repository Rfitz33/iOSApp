//
//  GameManager+Equipment.swift
//  LocationBasedGame
//
//  Created by Reid on 7/10/25.
//
import Foundation

// In a new file GameManager+Equipment.swift or within GameManager.swift
extension GameManager {
    func equipItem(_ itemToEquip: ItemType) {
        guard let slot = itemToEquip.equipmentSlot else { return }
        guard (sanctumItemStorage[itemToEquip] ?? 0) > 0 else { return }
        
        // Unequip any existing item in that slot and return it to inventory
        if let currentlyEquipped = equippedGear[slot] {
            sanctumItemStorage[currentlyEquipped, default: 0] += 1
        }
        
        // Decrement from inventory and equip new item
        sanctumItemStorage[itemToEquip, default: 0] -= 1
        equippedGear[slot] = itemToEquip
    }
    
    func unequipItem(from slot: EquipmentSlot) {
        guard let itemToUnequip = equippedGear[slot] else { return }
        // Check for inventory capacity before unequipping! For now, assume it fits.
        sanctumItemStorage[itemToUnequip, default: 0] += 1
        equippedGear.removeValue(forKey: slot)
    }
    
    // This method recalculates all bonuses from equipped gear.
    // Call this whenever equippedGear changes.
    func recalculateAllBonuses() {
        var newBonuses: [PlayerStat: Double] = [:]
        
        for (_, item) in equippedGear {
            if let bonuses = item.statBonuses {
                for (stat, value) in bonuses {
                    newBonuses[stat, default: 0.0] += value
                }
            }
        }
        activeStatBonuses = newBonuses
        print("Recalculated active stat bonuses: \(activeStatBonuses)")
        
        // After stats are recalculated, capacity might change
        updateTotalResourceLoads()
    }
    
    // Persistence for equipped gear
    func saveEquippedGear() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(equippedGear)
            UserDefaults.standard.set(data, forKey: equippedGearStorageKey)
            print("Saved equipped gear.")
        } catch {
            print("!!! Failed to save equipped gear: \(error)")
        }
    }
    
    func loadEquippedGear() {
        if let savedData = UserDefaults.standard.data(forKey: equippedGearStorageKey) {
            do {
                let decoder = JSONDecoder()
                equippedGear = try decoder.decode([EquipmentSlot: ItemType].self, from: savedData)
                print("Loaded equipped gear: \(equippedGear.mapValues { $0.displayName })")
            } catch {
                print("!!! Failed to load/decode equipped gear: \(error)")
                equippedGear = [:]
            }
        } else {
            equippedGear = [:]
            print("No equipped gear found in storage.")
        }
    }
    
}
