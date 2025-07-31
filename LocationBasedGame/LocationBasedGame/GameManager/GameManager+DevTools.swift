//
//  GameManager+DevTools.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//
import Foundation

// MARK: - Scouts Logic
extension GameManager {
    
    func clearHomeBaseForTesting() { // Developer utility
        homeBase = nil
        saveHomeBase()
        print("Home Base cleared for testing.")
    }
    
    func clearActivePotionEffectsForTesting() {
        activePotionEffects = [:]
        // saveActivePotionEffects() called by didSet
        print("Active potion effects cleared.")
    }

    func clearInventoryForTesting() { // Developer utility
        playerInventory = [:]
        saveInventory() // This will also remove it from UserDefaults by saving an empty dict
        print("Player inventory cleared for testing.")
    }
    
    func clearBaseUpgradesForTesting() {
        activeBaseUpgrades = [] // Clear the set
        print("Base upgrades cleared.")
    }
    
    func clearScoutStateForTesting() {
        assignedScoutTask = nil
        // saveScoutState() called by didSet
        print("Scout state cleared.")
    }

    func clearToolDurabilityForTesting() {
        currentToolDurability = [:]
        // saveToolDurability() called by didSet
        print("Tool durability cleared.")
    }

    func clearItemInventoryForTesting() { // Developer utility
        sanctumItemStorage = [:]
        // saveItemInventory() will be called by didSet
        currentToolDurability = [:]
        print("Player item inventory cleared for testing.")
        print("Also cleared active tool durabilities due to item inventory clear.")
    }

    func clearSkillsForTesting() {
        playerSkillsXP = [:]
        updateAllSkillLevelsFromXP() // Recalculate levels to 1
        // saveSkillsState() called by didSet on playerSkillsXP
        print("Player skills cleared for testing.")
    }
    
    func clearAllPlayerDataForTesting() {
        clearHomeBaseForTesting()
        clearInventoryForTesting()
        clearItemInventoryForTesting()
        clearBaseUpgradesForTesting()
        clearSkillsForTesting()
        clearScoutStateForTesting()
        clearActivePotionEffectsForTesting()
        clearPetsForTesting()
        print("--- ALL PLAYER DATA RESET (Dev Tool) ---")
    }
}
