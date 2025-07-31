//
//  GameStats.swift
//  LocationBasedGame
//
//  Created by Reid on 7/10/25.
//
import Foundation

// Defines all the possible stats that gear can modify
enum PlayerStat: String, Codable, Hashable {
    // XP Bonuses
    case globalXpBonus
    case miningXpBonus
    case woodcuttingXpBonus
    case foragingXpBonus
    case huntingXpBonus
    // Crafting XP Bonuses
    case smithingXpBonus
    case carpentryXpBonus
    case leatherworkingXpBonus
    case alchemyXpBonus
    case fletchingXpBonus
    case jewelcraftingXpBonus
    
    // Gathering Bonuses
    case gatheringYieldBonus // General bonus to amount gathered
    case rareFindChanceBonus // General bonus to find gems, eggs, etc.
    case huntingSuccessChanceBonus // Specific bonus to hunting
    
    // Utility Bonuses
    case toolDurabilitySaver // % chance to not consume durability
    case generalCapacityBonus // Flat bonus to general carry capacity
    case herbCapacityBonus    // Flat bonus to herb carry capacity
    
    var displayName: String {
        switch self {
        case .globalXpBonus: return "+% to all XP gain"
        case .miningXpBonus: return "+% Mining XP"
        case .gatheringYieldBonus: return "+% bonus resource yield"
        case .toolDurabilitySaver: return "% chance to save tool durability"
        case .generalCapacityBonus: return "Increases general carry capacity"
        // ... add more descriptions ...
        default: return "A mysterious bonus"
        }
    }
}

enum EquipmentSlot: String, Codable, CaseIterable, Identifiable {
    case necklace, ring, backpack, satchel
    case pickaxe, axe, knife, bow, arrows
    var id: String { self.rawValue }
    // Add displayName, icon for UI later
    var iconName: String {
            switch self {
            case .necklace: return "amulet_symbol"
            case .ring: return "ring_symbol"
            case .backpack: return "backpack_symbol"
            case .satchel: return "satchel_symbol"
            case .pickaxe: return "pickaxe_symbol"
            case .axe: return "axe_symbol"
            case .knife: return "knife_symbol"
            case .bow: return "bow_symbol"
            case .arrows: return "arrows_symbol"
            }
        }
}
