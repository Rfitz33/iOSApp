//
//  GameSkills.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//

import Foundation
import SwiftUI

// MARK: - SkillUnlock Definition
struct SkillUnlock: Identifiable {
    let id = UUID()
    let levelRequired: Int
    let description: String
    let iconName: String? // Optional SF Symbol or asset name for the unlock itself
    let isMajorUnlock: Bool // To highlight significant unlocks

    // Initializer
    init(level: Int, description: String, iconName: String? = nil, major: Bool = false) {
        self.levelRequired = level
        self.description = description
        self.iconName = iconName
        self.isMajorUnlock = major
    }
}


enum SkillType: String, CaseIterable, Codable, Identifiable {
    case mining
    case smithing
    case woodcutting
    case carpentry
    case fletching
    case hunting
    case leatherworking
    case foraging
    case herblore
    case alchemy
    case jewelcrafting
    // Future crafting skills: case smithing, case carpentry, case fletching, case potionMaking, case tailoring

    var id: String { self.rawValue }
    
    var iconAssetName: String {
        switch self {
        case .mining: return "mining_icon"
        case .smithing: return "smithing_icon"
        case .woodcutting: return "woodcutting_icon"
        case .carpentry: return "carpentry_icon"
        case .fletching: return "fletching_icon"
        case .hunting: return "hunting_icon"
        case .leatherworking: return "leatherworking_icon"
        case .foraging: return "foraging_icon"
        case .herblore: return "herblore_icon"
        case .alchemy: return "alchemy_icon"
        case .jewelcrafting: return "jewelcrafting_icon"
        }
    }

    var displayName: String {
        switch self {
        case .mining: return "Mining"
        case .smithing: return "Smithing"
        case .woodcutting: return "Woodcutting"
        case .carpentry: return "Carpentry"
        case .fletching: return "Fletching"
        case .hunting: return "Hunting"
        case .leatherworking: return "Leatherworking"
        case .foraging: return "Foraging"
        case .herblore: return "Herblore"
        case .alchemy: return "Alchemy"
        case .jewelcrafting: return "Jewelcrafting"
        }
    }
    
// Computed property for level unlocks
    var levelUnlocks: [SkillUnlock] {
        switch self {
        case .mining:
            return [
                SkillUnlock(level: 1, description: "Gather Stone Fragments.", iconName: ResourceType.stone.mapIconAssetName, major: true),
                SkillUnlock(level: 1, description: "Use Makeshift Pickaxe.", iconName: ItemType.T0_pickaxe.iconAssetName),
                SkillUnlock(level: 1, description: "Use Copper Pickaxe.", iconName: ItemType.T1_pickaxe.iconAssetName),
                SkillUnlock(level: 2, description: "Gather Copper Ore (Tier 1). Requires Makeshift Pickaxe or better.", iconName: ResourceType.T1_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 2, description: "+ Slight chance for higher Stone yield."),
                SkillUnlock(level: 3, description: "+ Increased chance for no durability loss (Makeshift Pickaxe)."),
//                SkillUnlock(level: 4, description: "Iron Ore nodes may now appear.", iconName: ResourceType.T2_stone.mapIconAssetName),
                SkillUnlock(level: 5, description: "Gather Iron Ore (Tier 2). Requires Copper Pickaxe or better.", iconName: ResourceType.T2_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 5, description: "Unlock Basic Forge construction.", iconName: BaseUpgradeType.basicForge.iconForUI()), // Helper needed
                SkillUnlock(level: 5, description: "Unlock Storehouse construction with 5 Woodcutting & Hunting.", iconName: "placeholder_icon"),
                SkillUnlock(level: 5, description: "Unlock use of Iron Pickaxe!", iconName: ItemType.T2_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 6, description: "+ Slight chance for higher Iron Ore yield."),
                SkillUnlock(level: 7, description: "+5% chance for bonus Stone from nodes."),
                SkillUnlock(level: 8, description: "+ Increased chance for no durability loss when using Iron Pickaxe."),
//                SkillUnlock(level: 9, description: "T3_stone nodes may now appear.", iconName: ResourceType.T3_stone.mapIconAssetName),
                SkillUnlock(level: 10, description: "Unlock Fletching workshop with 15 Woodcutting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 10, description: "Unlock Watchtower & Alchemy lab with 10 Woodcutting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 10, description: "Unlock Scouts' Quarters with 10 Woodcutting & Hunting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 10, description: "Gather Darksteel Ore (Tier 3). Requires Iron Pickaxe.", iconName: ResourceType.T3_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 10, description: "+ Reduced durability loss for Copper & Iron Pickaxes."),
                SkillUnlock(level: 10, description: "Unlock use of Darksteel Pickaxe!", iconName: ItemType.T3_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 11, description: "+ Slight chance for higher Darksteel Ore yield."),
                SkillUnlock(level: 12, description: "+5% chance for bonus Iron ore from nodes."),
                SkillUnlock(level: 13, description: "+ Increased chance for no durability loss when using Darksteel Pickaxe."),
//                SkillUnlock(level: 14, description: "T4_stone nodes may now appear.", iconName: ResourceType.T4_stone.mapIconAssetName),
                SkillUnlock(level: 15, description: "Unlock Jewel Crafting Station. Chance of Rare gem (Sapphire) drop & Silver Ore node spawns.", iconName: "sapphireUncut", major: true),
                SkillUnlock(level: 15, description: "Gather Cobaltite Ore (Tier 4). Requires Darksteel Pickaxe or better.", iconName: ResourceType.T4_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 15, description: "Unlock use of Cobaltite Pickaxe!", iconName: ItemType.T4_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 16, description: "+ Slight chance for higher Cobaltite Ore yield."),
                SkillUnlock(level: 17, description: "+5% chance for bonus Darksteel Ore from nodes."),
                SkillUnlock(level: 18, description: "+ Increased chance for no durability loss when using Cobaltite Pickaxe."),
//                SkillUnlock(level: 19, description: "T5_stone nodes may now appear.", iconName: ResourceType.T5_stone.mapIconAssetName),
                SkillUnlock(level: 20, description: "Unlock Watchtower upgrade with 20 Woodcutting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 20, description: "Unlock Scouts' Quarters upgrade with 20 Woodcutting & Hunting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 20, description: "Gather Mithril Ore (Tier 5). Requires Cobaltite Pickaxe or better.", iconName: ResourceType.T5_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 20, description: "Unlock use of Mithril Pickaxe!", iconName: ItemType.T5_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 21, description: "Chance of Rare gem (Emerald) drop.", iconName: "emeraldUncut", major: true),
                SkillUnlock(level: 21, description: "+ Slight chance for higher Mithril Ore yield."),
                SkillUnlock(level: 22, description: "+5% chance for bonus Cobaltite Ore from nodes."),
                SkillUnlock(level: 23, description: "+ Increased chance for no durability loss when using Mithril Pickaxe."),
//                SkillUnlock(level: 24, description: "T6_stone nodes may now appear.", iconName: ResourceType.T6_stone.mapIconAssetName),
                SkillUnlock(level: 25, description: "Gather Obsidian Ore (Tier 6). Requires Mithril Pickaxe or better.", iconName: ResourceType.T6_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 25, description: "Unlock use of Obsidian Pickaxe!", iconName: ItemType.T6_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 26, description: "+ Slight chance for higher Obsidian Ore yield."),
                SkillUnlock(level: 27, description: "Chance of Rare gem (Ruby) drop.", iconName: "rubyUncut", major: true),
                SkillUnlock(level: 27, description: "+5% chance for bonus Mithril Ore from nodes."),
                SkillUnlock(level: 28, description: "+ Increased chance for no durability loss when using Obsidian Pickaxe."),
//                SkillUnlock(level: 29, description: "T7_stone nodes may now appear.", iconName: ResourceType.T7_stone.mapIconAssetName),
                SkillUnlock(level: 30, description: "Unlock Watchtower upgrade with 30 Woodcutting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 30, description: "Unlock Scouts' Quarters upgrade with 30 Woodcutting & Hunting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 30, description: "Gather Nacreum Ore (Tier 7). Requires Obsidian Pickaxe or better.", iconName: ResourceType.T7_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 30, description: "Unlock use of Naecreum Pickaxe!", iconName: ItemType.T7_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 31, description: "+ Slight chance for higher Nacreum Ore yield."),
                SkillUnlock(level: 32, description: "+5% chance for bonus Obsidian Ore from nodes."),
                SkillUnlock(level: 33, description: "Chance of Rare gem (Diamond) drop & Gold Ore node spawns.", iconName: "diamondUncut", major: true),
                SkillUnlock(level: 33, description: "+ Increased chance for no durability loss when using Nacreum Pickaxe."),
//                SkillUnlock(level: 34, description: "T8_stone nodes may now appear.", iconName: ResourceType.T8_stone.mapIconAssetName),
                SkillUnlock(level: 35, description: "Gather Ubronium Ore (Tier 8). Requires Nacreum Pickaxe or better.", iconName: ResourceType.T8_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 35, description: "Unlock use of Ubronium Pickaxe!", iconName: ItemType.T8_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 36, description: "+ Slight chance for higher Ubronium Ore yield."),
                SkillUnlock(level: 37, description: "+5% chance for bonus Nacreum Ore from nodes."),
                SkillUnlock(level: 38, description: "+ Increased chance for no durability loss when using Ubronium Pickaxe."),
                SkillUnlock(level: 39, description: "Chance of Rare gem (Onyx) drop.", iconName: "onyxUncut", major: true),
//                SkillUnlock(level: 39, description: "T9_stone nodes may now appear.", iconName: ResourceType.T9_stone.mapIconAssetName),
                SkillUnlock(level: 40, description: "Unlock Watchtower upgrade with 40 Woodcutting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 40, description: "Unlock Scouts' Quarters upgrade with 40 Woodcutting & Hunting.", iconName: "placeholder_icon", major: true),
                SkillUnlock(level: 40, description: "Gather Mantleborn Ore (Tier 9). Requires Ubronium Pickaxe or better.", iconName: ResourceType.T9_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 40, description: "Unlock use of Mantleborn Pickaxe!", iconName: ItemType.T9_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 41, description: "+ Slight chance for higher Mantleborn Ore yield."),
                SkillUnlock(level: 42, description: "+5% chance for bonus Ubronium Ore from nodes."),
                SkillUnlock(level: 43, description: "+ Increased chance for no durability loss when using Mantleborn Pickaxe."),
//                SkillUnlock(level: 44, description: "T10_stone nodes may now appear.", iconName: ResourceType.T10_stone.mapIconAssetName),
                SkillUnlock(level: 45, description: "Chance of Rare gem (Dragonstone) drop.", iconName: "dragonstoneUncut", major: true),
                SkillUnlock(level: 45, description: "Gather Novaheart Ore (Tier 10). Requires Mantleborn Pickaxe or better.", iconName: ResourceType.T10_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 45, description: "Unlock use of Novaheart Pickaxe!", iconName: ItemType.T10_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 46, description: "+ Slight chance for higher Novaheart Ore yield."),
                SkillUnlock(level: 47, description: "+5% chance for bonus Mantleborn Ore from nodes."),
                SkillUnlock(level: 48, description: "+ Increased chance for no durability loss when using Novaheart Pickaxe."),
//                SkillUnlock(level: 49, description: "T11_stone nodes may now appear.", iconName: ResourceType.T11_stone.mapIconAssetName),
                SkillUnlock(level: 50, description: "Gather Dragonvein Ore (Tier 11). Requires Novaheart Pickaxe or better.", iconName: ResourceType.T11_stone.inventoryIconAssetName, major: true),
                SkillUnlock(level: 50, description: "Unlock use of Master Dragonvein Pickaxe!", iconName: ItemType.T11_pickaxe.iconAssetName, major: true),
                SkillUnlock(level: 50, description: "Mining Mastery!", iconName: "star.fill", major: true)
            ]
        case .woodcutting:
            return [
                SkillUnlock(level: 1, description: "Gather Glimmerwood.", iconName: ResourceType.T1_wood.inventoryIconAssetName, major: true),
                SkillUnlock(level: 1, description: "Use Makeshift Axe.", iconName: ItemType.T1_axe.iconAssetName),
                SkillUnlock(level: 2, description: "+ Slight chance for higher Glimmerwood yield."),
                SkillUnlock(level: 4, description: "Hardwood Logs may now appear.", iconName: ResourceType.T2_wood.mapIconAssetName),
                SkillUnlock(level: 5, description: "Gather Hardwood Logs (requires Iron Axe).", iconName: ResourceType.T2_wood.inventoryIconAssetName, major: true),
                SkillUnlock(level: 5, description: "Unlock Woodworking Shop construction.", iconName: BaseUpgradeType.woodworkingShop.iconForUI()),
                SkillUnlock(level: 5, description: "Unlock Iron Axe recipe.", iconName: ItemType.T2_axe.iconAssetName),
                // ... continue ...
                SkillUnlock(level: 50, description: "Woodcutting Mastery!", iconName: "star.fill", major: true)
            ]
        case .foraging:
            return [
                SkillUnlock(level: 1, description: "Gather Sunpetal & Mana Crystals.", iconName: ResourceType.T1_herb.inventoryIconAssetName, major: true),
                SkillUnlock(level: 2, description: "+ Slight chance for higher herb/crystal yield."),
                SkillUnlock(level: 5, description: "Unlock Apothecary Stand construction.", iconName: BaseUpgradeType.apothecaryStand.iconForUI()),
                SkillUnlock(level: 6, description: "Moonpetal may now appear.", iconName: ResourceType.T2_herb.mapIconAssetName),
                SkillUnlock(level: 7, description: "Gather Moonpetal.", iconName: ResourceType.T2_herb.inventoryIconAssetName, major: true),
                // ... continue ...
                SkillUnlock(level: 50, description: "Foraging Mastery!", iconName: "star.fill", major: true)
            ]
        case .hunting:
            return [
                SkillUnlock(level: 1, description: "Basic hunting skills.", major: true),
                SkillUnlock(level: 50, description: "Hunting Mastery!", iconName: "star.fill", major: true)
            ]
        // For crafting skills, unlocks are primarily new recipes.
        case .smithing:
            return [
                SkillUnlock(level: 1, description: "Craft Copper Ingots, Copper Tool Heads.", iconName: ComponentType.T1_ingot.iconAssetName, major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Metal] Ingots smithing."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Metal] Ingots smithing."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Metal] Ingots smithing."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Metal] Ingots smithing."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Metal] Ingots smithing."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Metal] Ingots smithing."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Metal] Ingots smithing."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Metal] Ingots smithing."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Metal] Ingots smithing."),
                SkillUnlock(level: 50, description: "Smithing Mastery!", iconName: "star.fill", major: true)
            ]
        case .carpentry:
            return [
                SkillUnlock(level: 1, description: "Craft Wooden Planks, Wooden Boards.", iconName: ComponentType.T1_plank.iconAssetName, major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Wood] Planks crafting."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Wood] Planks crafting."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Wood] Planks crafting."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Wood] Planks crafting."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Wood] Planks crafting."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Wood] Planks crafting."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Wood] Planks crafting."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Wood] Planks crafting."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Wood] Planks crafting."),
                SkillUnlock(level: 50, description: "Carpentry Mastery!", iconName: "star.fill", major: true)
            ]
        case .alchemy:
            return [
                SkillUnlock(level: 1, description: "Craft Basic Potions, Elixirs.", iconName: ItemType.T1_potion.iconAssetName, major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Alchemy] resource combination."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Alchemy] resource combination."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Alchemy] resource combination."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Alchemy] resource combination."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Alchemy] resource combination."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Alchemy] resource combination."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Alchemy] resource combination."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Alchemy] resource combination."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Alchemy] resource combination."),
                SkillUnlock(level: 50, description: "Alchemy Mastery!", iconName: "star.fill", major: true)
            ]
        case .leatherworking:
            return [
                SkillUnlock(level: 1, description: "Basic leatherworking skills.", major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Leatherworking] hide tanning."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Leatherworking] hide tanning."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Leatherworking] hide tanning."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Leatherworking] hide tanning."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Leatherworking] hide tanning."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Leatherworking] hide tanning."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Leatherworking] hide tanning."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Leatherworking] hide tanning."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Leatherworking] hide tanning."),
                SkillUnlock(level: 50, description: "Leatherworking Mastery!", iconName: "star.fill", major: true)
            ]
        case .herblore:
            return [
                SkillUnlock(level: 1, description: "Basic herblore skills.", major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Herblore] potion crafting."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Herblore] potion crafting."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Herblore] potion crafting."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Herblore] potion crafting."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Herblore] potion crafting."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Herblore] potion crafting."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Herblore] potion crafting."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Herblore] potion crafting."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Herblore] potion crafting."),
                SkillUnlock(level: 50, description: "Herblore Mastery!", iconName: "star.fill", major: true)
            ]
        case .fletching:
            return [
                SkillUnlock(level: 1, description: "Basic fletching skills.", major: true),
                SkillUnlock(level: 5, description: "Unlock [Tier 2 Fletching] bow crafting."),
                SkillUnlock(level: 10, description: "Unlock [Tier 3 Fletching] bow crafting."),
                SkillUnlock(level: 15, description: "Unlock [Tier 4 Fletching] bow crafting."),
                SkillUnlock(level: 20, description: "Unlock [Tier 5 Fletching] bow crafting."),
                SkillUnlock(level: 25, description: "Unlock [Tier 6 Fletching] bow crafting."),
                SkillUnlock(level: 30, description: "Unlock [Tier 7 Fletching] bow crafting."),
                SkillUnlock(level: 35, description: "Unlock [Tier 8 Fletching] bow crafting."),
                SkillUnlock(level: 40, description: "Unlock [Tier 9 Fletching] bow crafting."),
                SkillUnlock(level: 45, description: "Unlock [Tier 10 Fletching] bow crafting."),
                SkillUnlock(level: 50, description: "Fletching Mastery!", iconName: "star.fill", major: true)
            ]
        default:
            return [SkillUnlock(level: 1, description: "Basic functionality.", major: true),
                    SkillUnlock(level: 50, description: "Skill Mastery!", iconName: "star.fill", major: true)]
        }
    }
}

// Helper on BaseUpgradeType to get an icon for UI (add to BaseUpgradeType enum file)
extension BaseUpgradeType {
    func iconForUI() -> String { // Returns SF Symbol name for now
        switch self {
        case .basicForge: return "smithing_icon"
        case .woodworkingShop: return "carpentry_icon"
        case .tanningRack: return "leatherworking_icon"
        case .apothecaryStand: return "herblore_icon"
        case .scoutsQuarters: return "person.2.fill"
        case .basicStorehouse: return "archivebox.fill"
        case .garden: return "leaf.fill"
        case .alchemyLab: return "alchemy_icon"
        case .watchtower: return "binoculars.fill"
        case .aviary: return "bird.fill"
        case .jewelCraftingWorkshop: return "jewelcrafting_icon"
        case .fletchingWorkshop: return "fletching_icon"
        }
    }
}
