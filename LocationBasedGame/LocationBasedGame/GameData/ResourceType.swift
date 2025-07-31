import Foundation
import CoreLocation // For CLLocationCoordinate2D
import SwiftUI // For Color, Image (systemName)

    // Enum for Resource Categories
enum ResourceCategory: String, CaseIterable {
        case herb          // For Sunpetal, Moonpetal, etc. (affected by Satchels)
        case wood          // Glimmerwood, Hardwood (affected by Backpacks/Storehouse)
        case stoneOre      // Stone or Ore (affected by Backpacks/Storehouse)
        case hide          // Rawhide (affected by Backpacks/Storehouse)
        case uncategorized // For things like AnimalTracks that aren't "carried"
        
    var displayOrder: Int {
           switch self {
           case .herb: return 1
           case .wood: return 2
           case .stoneOre: return 3
           case .hide: return 4
           case .uncategorized: return 99
           }
       }
    }

enum ToolCategory: String, CaseIterable, Identifiable { // Added String, CaseIterable, Identifiable
    case pickaxe, axe, knife, bow, arrows, none
    
    var id: String { self.rawValue } // For Identifiable conformance
}

    // Special items
    enum ItemTag {
        case rareDrop // For items that can't be dropped, etc.
        case egg
    }

    // Enum for different types of resources
    enum ResourceType: String, CaseIterable, Codable, Identifiable {
            
    // --- RARE DROPS ---
       case feathers
       // Gems
        case T1_gemstone, T2_gemstone, T3_gemstone, T4_gemstone, T5_gemstone, T6_gemstone
       // Eggs
       case ravenEgg, owlEgg, hawkEgg, dragonEgg
       // Precious Metal Ores (these will spawn on the map)
       case silverOre, goldOre, platinumOre
        
        case stone
        case T0_wood
        case T1_stone, T1_tracks, T1_hide, T1_wood, T1_herb
        case T2_stone, T2_tracks, T2_hide, T2_wood, T2_herb
        case T3_stone, T3_tracks, T3_hide, T3_wood, T3_herb
        case T4_stone, T4_tracks, T4_hide, T4_wood, T4_herb
        case T5_stone, T5_tracks, T5_hide, T5_wood, T5_herb
        case T6_stone, T6_tracks, T6_hide, T6_wood, T6_herb
        case T7_stone, T7_tracks, T7_hide, T7_wood, T7_herb
        case T8_stone, T8_tracks, T8_hide, T8_wood, T8_herb
        case T9_stone, T9_tracks, T9_hide, T9_wood, T9_herb
        case T10_stone, T10_tracks, T10_hide, T10_wood, T10_herb
        case T11_stone, T11_tracks, T11_hide, T11_wood, T11_herb
        
        
    var category: ResourceCategory {
        switch self {
        case .T1_herb, .T2_herb, .T3_herb, .T4_herb, .T5_herb, .T6_herb, .T7_herb, .T8_herb, .T9_herb, .T10_herb, .T11_herb:
            return .herb
        case .T0_wood, .T1_wood, .T2_wood, .T3_wood, .T4_wood, .T5_wood, .T6_wood, .T7_wood, .T8_wood, .T9_wood, .T10_wood, .T11_wood:
            return .wood
        case .stone, .silverOre, .goldOre, .platinumOre, .T1_stone, .T2_stone, .T3_stone, .T4_stone, .T5_stone, .T6_stone, .T7_stone, .T8_stone, .T9_stone, .T10_stone, .T11_stone:
            return .stoneOre
        case .T1_hide, .T2_hide, .T3_hide, .T4_hide, .T5_hide, .T6_hide, .T7_hide, .T8_hide, .T9_hide, .T10_hide, .T11_hide:
            return .hide
        case .feathers, .ravenEgg, .owlEgg, .hawkEgg, .dragonEgg, .T1_tracks, .T2_tracks, .T3_tracks, .T4_tracks, .T5_tracks, .T6_tracks, .T7_tracks, .T8_tracks, .T9_tracks, .T10_tracks, .T11_tracks, .T1_gemstone, .T2_gemstone, .T3_gemstone, .T4_gemstone, .T5_gemstone, .T6_gemstone:
            return .uncategorized // Tracks aren't carried
        }
    }
        
    var id: String { self.rawValue }
    
    // Properties for display
    var displayName: String {
        switch self {
            
        case .feathers: return "Bird Feathers"
        case .ravenEgg: return "Raven Egg"
        case .owlEgg: return "Owl Egg"
        case .hawkEgg: return "Hawk Egg"
        case .dragonEgg: return "Dragon Egg"
        
        case .stone: return "Stone Deposit"
        case .silverOre: return "Silver Ore Chunk"
        case .goldOre: return "Gold Ore Chunk"
        case .platinumOre: return "Platinum Ore Chunk"
        case .T0_wood: return "Wood Logs"
        case .T1_stone: return "Copper Ore Chunk"
        case .T2_stone: return "Iron Ore Chunk"
        case .T3_stone: return "Darksteel Ore Chunk"
        case .T4_stone: return "Cobaltite Ore Chunk"
        case .T5_stone: return "Mithril Ore Chunk"
        case .T6_stone: return "Obsidian Ore Chunk"
        case .T7_stone: return "Nacreum Ore Chunk"
        case .T8_stone: return "Ubronium Ore Chunk"
        case .T9_stone: return "Mantleborn Ore Chunk"
        case .T10_stone: return "Novaheart Chunk"
        case .T11_stone: return "Dragonvein Ore Chunk"
            
        case .T1_tracks: return "Field Hare Tracks"
        case .T1_hide: return "Field Hare Pelt"
        case .T2_tracks: return "Forest Deer Tracks"
        case .T2_hide: return "Forest Deer Hide"
        case .T3_tracks: return "Moonlight Lynx Tracks"
        case .T3_hide: return "Moonlight Lynx Hide"
        case .T4_tracks: return "Wild Boar Tracks"
        case .T4_hide: return "Wild Boar Hide"
        case .T5_tracks: return "Mist Elk Tracks"
        case .T5_hide: return "Mist Elk Hide"
        case .T6_tracks: return "Dire Wolf Tracks"
        case .T6_hide: return "Dire Wolf Pelt"
        case .T7_tracks: return "Shadow Panther Tracks"
        case .T7_hide: return "Shadow Panther Hide"
        case .T8_tracks: return "Kodiak Bear Tracks"
        case .T8_hide: return "Kodiak Bear Hide"
        case .T9_tracks: return "Sabretooth Tracks"
        case .T9_hide: return "Sabretooth Hide"
        case .T10_tracks: return "Storm Basalisk Tracks"
        case .T10_hide: return "Storm Basalisk Hide"
        case .T11_tracks: return "Fire Drake Tracks"
        case .T11_hide: return "Fire Drake Hide"
            
        case .T1_wood: return "Willow Logs"
        case .T2_wood: return "White Birch Logs"
        case .T3_wood: return "Walnut Tree Logs"
        case .T4_wood: return "Black Cherry Logs"
        case .T5_wood: return "Lignum Vitae Logs"
        case .T6_wood: return "Red Oak Logs"
        case .T7_wood: return "Obsidianheart Logs"
        case .T8_wood: return "Silvershard Logs"
        case .T9_wood: return "Ebony Tree Logs"
        case .T10_wood: return "Starbloom Oak Logs"
        case .T11_wood: return "Aetherbloom Logs"
            
        case .T1_herb: return "Common Basil Leaf"
        case .T2_herb: return "Dandelion Petal"
        case .T3_herb: return "Lavendar Bud"
        case .T4_herb: return "Rosehip Cluster"
        case .T5_herb: return "Watermelon Leaf"
        case .T6_herb: return "Sunpetal Flower"
        case .T7_herb: return "Frostcap Mushroom"
        case .T8_herb: return "Bloodthorn Berry"
        case .T9_herb: return "Shadow Lily"
        case .T10_herb: return "Starbloom Lily"
        case .T11_herb: return "Dragonvine Spore"
            
        case .T1_gemstone: return "Uncut Sapphire Gemstone"
        case .T2_gemstone: return "Uncut Emerald Gemstone"
        case .T3_gemstone: return "Uncut Ruby Gemstone"
        case .T4_gemstone: return "Uncut Diamond Gemstone"
        case .T5_gemstone: return "Uncut Onyx Gemstone"
        case .T6_gemstone: return "Uncut Dragonstone Gemstone"
        }
    }
        
    var description: String {
        switch self {
    // Misc.
        case .feathers: return "Soft, lightweight feathers used for fletching arrows."
        case .ravenEgg: return "Unhatched Raven Egg"
        case .owlEgg: return "Unhatched Owl Egg"
        case .hawkEgg: return "Unhatched Hawk Egg"
        case .dragonEgg: return "Unhatched Dragon Egg"
    // Foraging
        case .T1_herb: return "Common Basil Leaf"
        case .T2_herb: return "Dandelion Petal"
        case .T3_herb: return "Lavendar Bud"
        case .T4_herb: return "Rosehip Cluster"
        case .T5_herb: return "Watermelon Leaf"
        case .T6_herb: return "Sunpetal Flower"
        case .T7_herb: return "Frostcap Mushroom"
        case .T8_herb: return "Bloodthorn Berry"
        case .T9_herb: return "Shadow Lily"
        case .T10_herb: return "Starbloom Lily"
        case .T11_herb: return "Dragonvine Spore"
        
    // Woodcutting
        case .T0_wood: return "Wood Logs"
        case .T1_wood: return "Willow Logs"
        case .T2_wood: return "White Birch Logs"
        case .T3_wood: return "Walnut Tree Logs"
        case .T4_wood: return "Black Cherry Logs"
        case .T5_wood: return "Lignum Vitae Logs"
        case .T6_wood: return "Red Oak Logs"
        case .T7_wood: return "Obsidianheart Logs"
        case .T8_wood: return "Silvershard Logs"
        case .T9_wood: return "Ebony Tree Logs"
        case .T10_wood: return "Starbloom Oak Logs"
        case .T11_wood: return "Aetherbloom Logs"
    // Mining
        case .stone: return "Basic stone fragments, useful for construction and rudimentary tools."
        case .silverOre: return "Silver Ore Chunk"
        case .goldOre: return "Gold Ore Chunk"
        case .platinumOre: return "Platinum Ore Chunk"
            
        case .T1_stone: return "Copper Ore Chunk"
        case .T2_stone: return "Iron Ore Chunk"
        case .T3_stone: return "Darksteel Ore Chunk"
        case .T4_stone: return "Cobaltite Ore Chunk"
        case .T5_stone: return "Mithril Ore Chunk"
        case .T6_stone: return "Obsidian Ore Chunk"
        case .T7_stone: return "Nacreum Ore Chunk"
        case .T8_stone: return "Ubronium Ore Chunk"
        case .T9_stone: return "Mantleborn Ore Chunk"
        case .T10_stone: return "Novaheart Chunk"
        case .T11_stone: return "Dragonvein Ore Chunk"
        
    // Hunting
        case .T1_tracks: return "Field Hare Tracks"
        case .T1_hide: return "Field Hare Pelt"
        case .T2_tracks: return "Forest Deer Tracks"
        case .T2_hide: return "Forest Deer Hide"
        case .T3_tracks: return "Moonlight Lynx Tracks"
        case .T3_hide: return "Moonlight Lynx Hide"
        case .T4_tracks: return "Wild Boar Tracks"
        case .T4_hide: return "Wild Boar Hide"
        case .T5_tracks: return "Mist Elk Tracks"
        case .T5_hide: return "Mist Elk Hide"
        case .T6_tracks: return "Dire Wolf Tracks"
        case .T6_hide: return "Dire Wolf Pelt"
        case .T7_tracks: return "Shadow Panther Tracks"
        case .T7_hide: return "Shadow Panther Hide"
        case .T8_tracks: return "Kodiak Bear Tracks"
        case .T8_hide: return "Kodiak Bear Hide"
        case .T9_tracks: return "Sabretooth Tracks"
        case .T9_hide: return "Sabretooth Hide"
        case .T10_tracks: return "Storm Basalisk Tracks"
        case .T10_hide: return "Storm Basalisk Hide"
        case .T11_tracks: return "Fire Drake Tracks"
        case .T11_hide: return "Fire Drake Hide"
//        case .hareTracks: return "Signs of wildlife activity. Following them might lead to a successful hunt."
//        case .rawhide: return "Untreated animal hide, a primary material for leatherworking."
//        case .hogTracks: return "Signs of wildlife activity. Following them might lead to a successful hunt."
//        case .hogHide: return "Untreated animal hide, a primary material for leatherworking."
        
    // Jewelcrafting
        case .T1_gemstone: return "Uncut Sapphire Gemstone"
        case .T2_gemstone: return "Uncut Emerald Gemstone"
        case .T3_gemstone: return "Uncut Ruby Gemstone"
        case .T4_gemstone: return "Uncut Diamond Gemstone"
        case .T5_gemstone: return "Uncut Onyx Gemstone"
        case .T6_gemstone: return "Uncut Dragonstone Gemstone"
            
        }
    }
    
    var mapIconAssetName: String {
        switch self {
           
        case .feathers: return "Feathers1"
        case .ravenEgg: return "T1_egg"
        case .owlEgg: return "T2_egg"
        case .hawkEgg: return "T3_egg"
        case .dragonEgg: return "T4_egg"
            
        case .silverOre: return "silver_deposit"
        case .goldOre: return "gold_deposit"
        case .platinumOre: return "platinum_deposit"
            
        case .stone: return "T0_stone"
        case .T1_stone: return "T1_stone"
        case .T2_stone: return "T2_stone"
        case .T3_stone: return "T3_stone"
        case .T4_stone: return "T4_stone"
        case .T5_stone: return "T5_stone"
        case .T6_stone: return "T6_stone"
        case .T7_stone: return "T7_stone"
        case .T8_stone: return "T8_stone"
        case .T9_stone: return "T9_stone"
        case .T10_stone: return "T10_stone"
        case .T11_stone: return "T11_stone"
            
        case .T1_tracks: return "T1_tracks"
        case .T2_tracks: return "T2_tracks"
        case .T3_tracks: return "T3_tracks"
        case .T4_tracks: return "T4_tracks"
        case .T5_tracks: return "T5_tracks"
        case .T6_tracks: return "T6_tracks"
        case .T7_tracks: return "T7_tracks"
        case .T8_tracks: return "T8_tracks"
        case .T9_tracks: return "T9_tracks"
        case .T10_tracks: return "T10_tracks"
        case .T11_tracks: return "T11_tracks"
            
        case .T1_hide: return "T1_hide"
        case .T2_hide: return "T2_hide"
        case .T3_hide: return "T3_hide"
        case .T4_hide: return "T4_hide"
        case .T5_hide: return "T5_hide"
        case .T6_hide: return "T6_hide"
        case .T7_hide: return "T7_hide"
        case .T8_hide: return "T8_hide"
        case .T9_hide: return "T9_hide"
        case .T10_hide: return "T10_hide"
        case .T11_hide: return "T11_hide"
            
        case .T0_wood: return "T0_tree"
        case .T1_wood: return "T1_tree"
        case .T2_wood: return "T2_tree"
        case .T3_wood: return "T3_tree"
        case .T4_wood: return "T4_tree"
        case .T5_wood: return "T5_tree"
        case .T6_wood: return "T6_tree"
        case .T7_wood: return "T7_tree"
        case .T8_wood: return "T8_tree"
        case .T9_wood: return "T9_tree"
        case .T10_wood: return "T10_tree"
        case .T11_wood: return "T11_tree"
            
        case .T1_herb: return "T1_plant"
        case .T2_herb: return "T2_plant"
        case .T3_herb: return "T3_plant"
        case .T4_herb: return "T4_plant"
        case .T5_herb: return "T5_plant"
        case .T6_herb: return "T6_plant"
        case .T7_herb: return "T7_plant"
        case .T8_herb: return "T8_plant"
        case .T9_herb: return "T9_plant"
        case .T10_herb: return "T10_plant"
        case .T11_herb: return "T11_plant"
    // Jewelcrafting
        case .T1_gemstone: return "sapphireUncut"
        case .T2_gemstone: return "emeraldUncut"
        case .T3_gemstone: return "rubyUncut"
        case .T4_gemstone: return "diamondUncut"
        case .T5_gemstone: return "onyxUncut"
        case .T6_gemstone: return "dragonstoneUncut"
            
        }
    }
        
    var inventoryIconAssetName: String {
        switch self {
        
        case .feathers: return "feathers1"
        case .ravenEgg: return "T1_egg"
        case .owlEgg: return "T2_egg"
        case .hawkEgg: return "T3_egg"
        case .dragonEgg: return "T4_egg"
            
        case .silverOre: return "silver_ore"
        case .goldOre: return "gold_ore"
        case .platinumOre: return "platinum_ore"
            
        case .stone: return "T0_stone_icon"
        case .T1_stone: return "T1_stone_icon"
        case .T2_stone: return "T2_stone_icon"
        case .T3_stone: return "T3_stone_icon"
        case .T4_stone: return "T4_stone_icon"
        case .T5_stone: return "T5_stone_icon"
        case .T6_stone: return "T6_stone_icon"
        case .T7_stone: return "T7_stone_icon"
        case .T8_stone: return "T8_stone_icon"
        case .T9_stone: return "T9_stone_icon"
        case .T10_stone: return "T10_stone_icon"
        case .T11_stone: return "T11_stone_icon"
            
        case .T1_tracks: return "T1_tracks"
        case .T2_tracks: return "T2_tracks"
        case .T3_tracks: return "T3_tracks"
        case .T4_tracks: return "T4_tracks"
        case .T5_tracks: return "T5_tracks"
        case .T6_tracks: return "T6_tracks"
        case .T7_tracks: return "T7_tracks"
        case .T8_tracks: return "T8_tracks"
        case .T9_tracks: return "T9_tracks"
        case .T10_tracks: return "T10_tracks"
        case .T11_tracks: return "T11_tracks"
           
        case .T1_hide: return "T1_hide"
        case .T2_hide: return "T2_hide"
        case .T3_hide: return "T3_hide"
        case .T4_hide: return "T4_hide"
        case .T5_hide: return "T5_hide"
        case .T6_hide: return "T6_hide"
        case .T7_hide: return "T7_hide"
        case .T8_hide: return "T8_hide"
        case .T9_hide: return "T9_hide"
        case .T10_hide: return "T10_hide"
        case .T11_hide: return "T11_hide"
            
        case .T0_wood: return "T0_wood"
        case .T1_wood: return "T1_wood"
        case .T2_wood: return "T2_wood"
        case .T3_wood: return "T3_wood"
        case .T4_wood: return "T4_wood"
        case .T5_wood: return "T5_wood"
        case .T6_wood: return "T6_wood"
        case .T7_wood: return "T7_wood"
        case .T8_wood: return "T8_wood"
        case .T9_wood: return "T9_wood"
        case .T10_wood: return "T10_wood"
        case .T11_wood: return "T11_wood"
            
        case .T1_herb: return "T1_plantInv"
        case .T2_herb: return "T2_plantInv"
        case .T3_herb: return "T3_plantInv"
        case .T4_herb: return "T4_plantInv"
        case .T5_herb: return "T5_plantInv"
        case .T6_herb: return "T6_plantInv"
        case .T7_herb: return "T7_plantInv"
        case .T8_herb: return "T8_plantInv"
        case .T9_herb: return "T9_plantInv"
        case .T10_herb: return "T10_plantInv"
        case .T11_herb: return "T11_plantInv"
    // Jewelcrafting
        case .T1_gemstone: return "sapphireUncut"
        case .T2_gemstone: return "emeraldUncut"
        case .T3_gemstone: return "rubyUncut"
        case .T4_gemstone: return "diamondUncut"
        case .T5_gemstone: return "onyxUncut"
        case .T6_gemstone: return "dragonstoneUncut"
            
        }
    }
    
    var iconColor: Color {
        switch self {
        case .feathers: return .brown
        case .ravenEgg: return .brown
        case .owlEgg: return .brown
        case .hawkEgg: return .brown
        case .dragonEgg: return .brown
            
        case .stone: return .gray
        case .silverOre: return .gray
        case .goldOre: return .yellow
        case .platinumOre: return .yellow
       
        case .T0_wood: return .brown
        case .T1_stone, .T1_tracks, .T1_hide, .T1_wood, .T1_herb: return .green
        case .T2_stone, .T2_tracks, .T2_hide, .T2_wood, .T2_herb: return .yellow
        case .T3_stone, .T3_tracks, .T3_hide, .T3_wood, .T3_herb: return .mint
        case .T4_stone, .T4_tracks, .T4_hide, .T4_wood, .T4_herb: return .orange
        case .T5_stone, .T5_tracks, .T5_hide, .T5_wood, .T5_herb: return .indigo
        case .T6_stone, .T6_tracks, .T6_hide, .T6_wood, .T6_herb: return .teal
        case .T7_stone, .T7_tracks, .T7_hide, .T7_wood, .T7_herb: return .pink
        case .T8_stone, .T8_tracks, .T8_hide, .T8_wood, .T8_herb: return .blue
        case .T9_stone, .T9_tracks, .T9_hide, .T9_wood, .T9_herb: return .black
        case .T10_stone, .T10_tracks, .T10_hide, .T10_wood, .T10_herb: return .white
        case .T11_stone, .T11_tracks, .T11_hide, .T11_wood, .T11_herb: return .red
        case .T1_gemstone, .T2_gemstone, .T3_gemstone, .T4_gemstone, .T5_gemstone, .T6_gemstone:
            return .white
        }
    }
        
    static func scoutGatherableTypes() -> [ResourceType] {
            // Define which basic resources scouts can be assigned to gather.
            return [.T1_herb, .T1_wood, .T1_stone]
        }
        
    // Add a new property for special item tags
        var tags: [ItemTag]? {
            switch self {
            case .feathers, .T1_gemstone, .T2_gemstone, .T3_gemstone, .T4_gemstone:
                return [.rareDrop]
            case .ravenEgg, .owlEgg, .hawkEgg, .dragonEgg:
                return [.rareDrop, .egg] // An egg is a rare drop that is also an egg
            default:
                return nil
            }
        }
    
    struct ToolRequirement {
            let primaryToolCategory: ToolCategory // e.g., .bow for initiating
            let secondaryToolCategory: ToolCategory? // e.g., .knife for processing
            let requiredArrowTier: Int? // Optional: for requiring specific arrows
        }

        // This replaces `requiredTool`.
        var toolRequirements: ToolRequirement? {
            switch self {
            case .stone, .T0_wood:
                return nil
            case .T1_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 1)
            case .T2_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 1)
            case .T3_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 1)
            case .T4_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 1)
            case .T5_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 2)
            case .T6_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 2)
            case .T7_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 3)
            case .T8_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 3)
            case .T9_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 4)
            case .T10_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 4)
            case .T11_tracks:
                return ToolRequirement(primaryToolCategory: .bow, secondaryToolCategory: .knife, requiredArrowTier: 5)
            // Ores require a pickaxe
            case .silverOre, .goldOre, .platinumOre, .T1_stone, .T2_stone, .T3_stone, .T4_stone, .T5_stone, .T6_stone, .T7_stone, .T8_stone, .T9_stone, .T10_stone, .T11_stone:
                return ToolRequirement(primaryToolCategory: .pickaxe, secondaryToolCategory: nil, requiredArrowTier: nil)
            // Wood requires an axe
            case .T1_wood, .T2_wood, .T3_wood, .T4_wood, .T5_wood, .T6_wood, .T7_wood, .T8_wood, .T9_wood, .T10_wood, .T11_wood:
                return ToolRequirement(primaryToolCategory: .axe, secondaryToolCategory: nil, requiredArrowTier: nil)
            default:
                return nil // Hand-gatherable
            }
        }
    
    var requiredSkillLevel: Int {
        switch self {
    // Mining
        case .silverOre: return 15
        case .goldOre: return 27
        case .platinumOre: return 39
            
        case .T1_stone: return 1
        case .T2_stone: return 5
        case .T3_stone: return 10
        case .T4_stone: return 15
        case .T5_stone: return 20
        case .T6_stone: return 25
        case .T7_stone: return 30
        case .T8_stone: return 35
        case .T9_stone: return 40
        case .T10_stone: return 45
    // Woodcutting
        case .T1_wood: return 1
        case .T2_wood: return 5
        case .T3_wood: return 10
        case .T4_wood: return 15
        case .T5_wood: return 20
        case .T6_wood: return 25
        case .T7_wood: return 30
        case .T8_wood: return 35
        case .T9_wood: return 40
        case .T10_wood: return 45
    // Hunting
        case .T1_tracks: return 1
        case .T2_tracks: return 5
        case .T3_tracks: return 10
        case .T4_tracks: return 15
        case .T5_tracks: return 20
        case .T6_tracks: return 25
        case .T7_tracks: return 30
        case .T8_tracks: return 35
        case .T9_tracks: return 40
        case .T10_tracks: return 45
    // Foraging
        case .T1_herb: return 1
        case .T2_herb: return 5
        case .T3_herb: return 10
        case .T4_herb: return 15
        case .T5_herb: return 20
        case .T6_herb: return 25
        case .T7_herb: return 30
        case .T8_herb: return 35
        case .T9_herb: return 40
        case .T10_herb: return 45
    // Default
        default:
            return 1
        }
    }
        
// Is this a "track" type resource that yields a different item?
    var isTrackType: Bool {
        switch self {
        case .T1_tracks, .T2_tracks, .T3_tracks, .T4_tracks, .T5_tracks, .T6_tracks, .T7_tracks, .T8_tracks, .T9_tracks, .T10_tracks, .T11_tracks:
            return true
        default:
            return false
        }
    }

    // What resource does this track yield on a successful hunt?
    var huntYieldType: ResourceType? {
        switch self {
        case .T1_tracks: return .T1_hide
        case .T2_tracks: return .T2_hide
        case .T3_tracks: return .T3_hide
        case .T4_tracks: return .T4_hide
        case .T5_tracks: return .T5_hide
        case .T6_tracks: return .T6_hide
        case .T7_tracks: return .T7_hide
        case .T8_tracks: return .T8_hide
        case .T9_tracks: return .T9_hide
        case .T10_tracks: return .T10_hide
        case .T11_tracks: return .T11_hide
        default: return nil
        }
    }
    
    // Base XP yield for successfully gathering this resource
    var baseXPYield: Int {
        switch self {
    // Foraging
        case .T1_herb: return 10
        case .T2_herb: return 20
        case .T3_herb: return 30
        case .T4_herb: return 30
        case .T5_herb: return 30
        case .T6_herb: return 50
        case .T7_herb: return 60
        case .T8_herb: return 70
        case .T9_herb: return 80
        case .T10_herb: return 90
        case .T11_herb: return 150
    // Woodcutting
        case .T0_wood: return 5
        case .T1_wood: return 10
        case .T2_wood: return 20
        case .T3_wood: return 30
        case .T4_wood: return 30
        case .T5_wood: return 30
        case .T6_wood: return 50
        case .T7_wood: return 60
        case .T8_wood: return 70
        case .T9_wood: return 80
        case .T10_wood: return 90
        case .T11_wood: return 150
    // Mining
        case .stone: return 3
        
        case .T1_stone: return 10
        case .T2_stone: return 20
        case .T3_stone: return 30
        case .T4_stone: return 30
        case .T5_stone: return 30
        case .T6_stone: return 60
        case .T7_stone: return 70
        case .T8_stone: return 80
        case .T9_stone: return 90
        case .T10_stone: return 100
        case .T11_stone: return 150
    // Hunting
        case .T1_tracks: return 20
        case .T2_tracks: return 30
        case .T3_tracks: return 30
        case .T4_tracks: return 30
        case .T5_tracks: return 30
        case .T6_tracks: return 50
        case .T7_tracks: return 60
        case .T8_tracks: return 70
        case .T9_tracks: return 80
        case .T10_tracks: return 90
        case .T11_tracks: return 150
    
        case .T1_hide, .T2_hide, .T3_hide, .T4_hide, .T5_hide, .T6_hide, .T7_hide, .T8_hide, .T9_hide, .T10_hide, .T11_hide: return 0
        default:
            return 0
        }
    }
    
    // Skill associated with gathering this resource
    var associatedSkill: SkillType? {
        switch self {
        case .silverOre, .goldOre, .platinumOre, .stone, .T1_stone, .T2_stone, .T3_stone, .T4_stone, .T5_stone, .T6_stone, .T7_stone, .T8_stone, .T9_stone, .T10_stone, .T11_stone: return .mining
        case .T0_wood, .T1_wood, .T2_wood, .T3_wood, .T4_wood, .T5_wood, .T6_wood, .T7_wood, .T8_wood, .T9_wood, .T10_wood, .T11_wood:
            return .woodcutting
        case .T1_herb, .T2_herb, .T3_herb, .T4_herb, .T5_herb, .T6_herb, .T7_herb, .T8_herb, .T9_herb, .T10_herb, .T11_herb:
            return .foraging
        case .T1_tracks, .T2_tracks, .T3_tracks, .T4_tracks, .T5_tracks, .T6_tracks, .T7_tracks, .T8_tracks, .T9_tracks, .T10_tracks, .T11_tracks:
            return .hunting
            // Resources that are products of gathering/crafting, not directly gathered from map nodes for skill XP
        case .T1_hide, .T2_hide, .T3_hide, .T4_hide, .T5_hide, .T6_hide, .T7_hide, .T8_hide, .T9_hide, .T10_hide, .T11_hide:
            return nil
        default:
            return nil
        }
    }
        
    var tier: Int {
        switch self {
        case .T0_wood, .stone:
            return 0
        case .T1_herb, .T1_wood, .T1_stone, .T1_tracks, .T1_hide:
            return 1
        case .T2_herb, .T2_wood, .T2_stone, .T2_tracks, .T2_hide:
            return 2
        case .T3_stone, .T3_tracks, .T3_hide, .T3_wood, .T3_herb:
            return 3
        case .silverOre, .T4_stone, .T4_tracks, .T4_hide, .T4_wood, .T4_herb:
            return 4
        case .T5_stone, .T5_tracks, .T5_hide, .T5_wood, .T5_herb:
            return 5
        case .T6_stone, .T6_tracks, .T6_hide, .T6_wood, .T6_herb:
            return 6
        case .goldOre, .T7_stone, .T7_tracks, .T7_hide, .T7_wood, .T7_herb:
            return 7
        case .T8_stone, .T8_tracks, .T8_hide, .T8_wood, .T8_herb:
            return 8
        case .platinumOre, .T9_stone, .T9_tracks, .T9_hide, .T9_wood, .T9_herb:
            return 9
        case .T10_stone, .T10_tracks, .T10_hide, .T10_wood, .T10_herb:
            return 10
        case .T11_stone, .T11_tracks, .T11_hide, .T11_wood, .T11_herb:
            return 11
        // Rare drops
        case .ravenEgg, .owlEgg, .hawkEgg, .dragonEgg, .feathers, .T1_gemstone, .T2_gemstone, .T3_gemstone, .T4_gemstone, .T5_gemstone, .T6_gemstone:
            return -1
        }
    }
}
        
        
    // Struct for a resource node instance on the map
    struct ResourceNode: Identifiable, Equatable {
        let id = UUID()
        var type: ResourceType
        var coordinate: CLLocationCoordinate2D
        
        // Base amount this node *could* yield before skill/tool modifiers.
        // For simplicity, we can keep this at 1 and let gather logic determine final yield,
        // OR we could make this a small range, e.g., Int.random(in: 1...3) when node spawns.
        // Let's keep it simple for now and assume gather logic handles variability.
        // var baseYieldAmount: Int = 1
        
        let spawnTime: Date         // When the node was created
        let lifespan: TimeInterval  // How long this node will exist (e.g., 15 minutes)
        var despawnTime: Date {     // Calculated property for when it should disappear
            spawnTime.addingTimeInterval(lifespan)
        }
        // --- Flag to mark enriched nodes ---
        var isEnriched: Bool
        // --- Flag for Watchtower "Horizon Scan" discoveries ---
        var isDiscovery: Bool
        
        static func == (lhs: ResourceNode, rhs: ResourceNode) -> Bool {
            lhs.id == rhs.id
        }
        
        // Initializer to include lifespan
        init(type: ResourceType, coordinate: CLLocationCoordinate2D, lifespan: TimeInterval? = nil,
             isEnriched: Bool = false, isDiscovery: Bool = false /* 15 minutes default */) {
            self.type = type
            self.coordinate = coordinate
            self.spawnTime = Date() // Set spawn time to current time on creation
            self.lifespan = lifespan ?? type.defaultLifespan
            self.isEnriched = isEnriched
            self.isDiscovery = isDiscovery
        }
    }

    extension ResourceType {
        var defaultLifespan: TimeInterval {
            switch self {
            case .silverOre, .goldOre, .platinumOre: return 60 * 30
            case .T1_herb, .T1_stone, .T1_wood, .T1_tracks: return 60 * 10 // 10 mins for least rarity
            case .T2_herb, .T2_stone, .T2_wood, .T2_tracks: return 60 * 15
            case .T3_herb, .T3_stone, .T3_wood, .T3_tracks: return 60 * 20
            case .T4_herb, .T4_stone, .T4_wood, .T4_tracks: return 60 * 25
            case .T5_herb, .T5_stone, .T5_wood, .T5_tracks: return 60 * 30
            case .T6_herb, .T6_stone, .T6_wood, .T6_tracks: return 60 * 35
            case .T7_herb, .T7_stone, .T7_wood, .T7_tracks: return 60 * 40
            case .T8_herb, .T8_stone, .T8_wood, .T8_tracks: return 60 * 45
            case .T9_herb, .T9_stone, .T9_wood, .T9_tracks: return 60 * 50
            case .T10_herb, .T10_stone, .T10_wood, .T10_tracks: return 60 * 55
            case .T11_herb, .T11_stone, .T11_wood, .T11_tracks: return 60 * 60
            default: return 60 * 15 // 15 mins default
            }
        }
    }
    
// Convenience for CLLocationCoordinate2D to be Codable if we ever need to save nodes
// (Not strictly needed if nodes are always dynamically spawned and not persisted)
extension CLLocationCoordinate2D: Codable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.latitude, forKey: .latitude) // self.latitude is fine here
        try container.encode(self.longitude, forKey: .longitude) // self.longitude is fine here
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        
        // Call the struct's memberwise initializer
        self.init(latitude: latitude, longitude: longitude)
    }
}

enum GenericIngredient: String, Codable {
    case anyStandardIngot
    // You could add others here in the future, like .anyPlank, .anyLeather, etc.
    
    var displayName: String {
        switch self {
        case .anyStandardIngot: return "Any Standard Ingot"
        }
    }
}

// MARK: - Components

enum ComponentCategory: String, CaseIterable {
    case smithing
    case carpentry
    case leatherworking
    case fletching
    case herblore
    case alchemy
    case jewelcrafting
    case uncategorized

    var displayOrder: Int {
        switch self {
        case .smithing: return 1
        case .carpentry: return 2
        case .leatherworking: return 3
        case .fletching: return 4
        case .herblore: return 5
        case .alchemy: return 6
        case .jewelcrafting: return 7
        case .uncategorized: return 99
        }
    }
}

enum ComponentType: String, CaseIterable, Codable, Identifiable {
    // Apothecary Components
            
        case T1_plantComp
        case T2_plantComp
        case T3_plantComp
        case T4_plantComp
        case T5_plantComp
        case T6_plantComp
        case T7_plantComp
        case T8_plantComp
        case T9_plantComp
        case T10_plantComp
        case T11_plantComp
    
    // Leatherworking Components
        case bowstring
    
        case T1_leather
        case T2_leather
        case T3_leather
        case T4_leather
        case T5_leather
        case T6_leather
        case T7_leather
        case T8_leather
        case T9_leather
        case T10_leather
        case T11_leather
    
    // Smithing Components
        case buckle
    
        case silverIngot
        case goldIngot
        case platinumIngot
    
        case T1_ingot
        case T2_ingot
        case T3_ingot
        case T4_ingot
        case T5_ingot
        case T6_ingot
        case T7_ingot
        case T8_ingot
        case T9_ingot
        case T10_ingot
        case T11_ingot
        
        case T0_pickaxeH
        case T1_pickaxeH
        case T2_pickaxeH
        case T3_pickaxeH
        case T4_pickaxeH
        case T5_pickaxeH
        case T6_pickaxeH
        case T7_pickaxeH
        case T8_pickaxeH
        case T9_pickaxeH
        case T10_pickaxeH
        case T11_pickaxeH
    
        case T0_axeHead
        case T1_axeHead
        case T2_axeHead
        case T3_axeHead
        case T4_axeHead
        case T5_axeHead
        case T6_axeHead
        case T7_axeHead
        case T8_axeHead
        case T9_axeHead
        case T10_axeHead
        case T11_axeHead
    
        case T0_knifeBlade
        case T1_knifeBlade
        case T2_knifeBlade
        case T3_knifeBlade
        case T4_knifeBlade
        case T5_knifeBlade
        case T6_knifeBlade
        case T7_knifeBlade
        case T8_knifeBlade
        case T9_knifeBlade
        case T10_knifeBlade
        case T11_knifeBlade
    
        case T1_aHead
        case T2_aHead
        case T3_aHead
        case T4_aHead
        case T5_aHead
        case T6_aHead
        case T7_aHead
        case T8_aHead
        case T9_aHead
        case T10_aHead
        case T11_aHead
    
    // Carpentry Components
        case T1_plank
        case T2_plank
        case T3_plank
        case T4_plank
        case T5_plank
        case T6_plank
        case T7_plank
        case T8_plank
        case T9_plank
        case T10_plank
        case T11_plank

        case T0_axeHandle
        case T1_axeHandle
        case T2_axeHandle
        case T3_axeHandle
        case T4_axeHandle
        case T5_axeHandle
        case T6_axeHandle
        case T7_axeHandle
        case T8_axeHandle
        case T9_axeHandle
        case T10_axeHandle
        case T11_axeHandle
    
        case T0_knifeHandle
        case T1_knifeHandle
        case T2_knifeHandle
        case T3_knifeHandle
        case T4_knifeHandle
        case T5_knifeHandle
        case T6_knifeHandle
        case T7_knifeHandle
        case T8_knifeHandle
        case T9_knifeHandle
        case T10_knifeHandle
        case T11_knifeHandle
    
    // Fletching Components
        case T1_shaft
        case T2_shaft
        case T3_shaft
        case T4_shaft
        case T5_shaft
        case T6_shaft
        case T7_shaft
        case T8_shaft
        case T9_shaft
        case T10_shaft
        case T11_shaft
    
        case T1_uBow
        case T2_uBow
        case T3_uBow
        case T4_uBow
        case T5_uBow
        case T6_uBow
        case T7_uBow
        case T8_uBow
        case T9_uBow
        case T10_uBow
        case T11_uBow
    // Jewelcrafting Components
        case T1_cutGemstone
        case T2_cutGemstone
        case T3_cutGemstone
        case T4_cutGemstone
        case T5_cutGemstone
        case T6_cutGemstone
    
    // New Alchemical Components
        case lesserStoneQuintessence // Example T2 result from T1 stone components
        case lesserWoodQuintessence  // Example T2 result from T1 wood components
        case lesserHerbQuintessence  // Example T2 result from T1 herb components
    
    var id: String { self.rawValue }
    
    var category: ComponentCategory {
        switch self {
        case .buckle, .silverIngot, .goldIngot, .platinumIngot,
             _ where self.rawValue.contains("ingot"),
             _ where self.rawValue.contains("pickaxeH"),
             _ where self.rawValue.contains("axeHead"),
             _ where self.rawValue.contains("knifeBlade"),
             _ where self.rawValue.contains("aHead"):
            return .smithing
            
        case _ where self.rawValue.contains("plank"),
             _ where self.rawValue.contains("axeHandle"),
             _ where self.rawValue.contains("knifeHandle"):
            return .carpentry
            
        case .bowstring,
             _ where self.rawValue.contains("leather"):
            return .leatherworking
            
        case _ where self.rawValue.contains("shaft"),
             _ where self.rawValue.contains("uBow"):
            return .fletching
            
        case _ where self.rawValue.contains("plantComp"):
            return .herblore
            
        case .lesserStoneQuintessence, .lesserWoodQuintessence, .lesserHerbQuintessence:
            return .alchemy
            
        case _ where self.rawValue.contains("cutGemstone"):
            return .jewelcrafting
            
        default:
            // This print statement is a fantastic debugging tool for you.
            // If you ever add a new component and forget to categorize it,
            // you will see this warning in your Xcode console.
            print("Warning: ComponentType '\(self.rawValue)' has no assigned category. Please update the `category` property.")
            return .uncategorized
        }
    }
    
    var displayName: String {
        switch self {
    // Apothecary Components
        case .T1_plantComp: return "Crushed Basil Leaf"
        case .T2_plantComp: return "Muddled Dandelion Petal"
        case .T3_plantComp: return "Ground Lavendar"
        case .T4_plantComp: return "Crushed Rosehip Cluster"
        case .T5_plantComp: return "Ground Watermelon Leaf"
        case .T6_plantComp: return "Muddled Sunpetal Flower"
        case .T7_plantComp: return "Minced Frostcap Mushroom"
        case .T8_plantComp: return "Ground Bloodthorn Berry"
        case .T9_plantComp: return "Crushed Shadow Lily Petals"
        case .T10_plantComp: return "Crushed Starbloom Lily Petals"
        case .T11_plantComp: return "Minced Dragonvine Spores"
            
    
    // Smithing Components
        case .buckle: return "Buckle"
            
        case .silverIngot: return "Silver Ingot"
        case .goldIngot: return "Gold Ingot"
        case .platinumIngot: return "Platinum Ingot"
            
        case .T1_ingot: return "Copper Ingot"
        case .T2_ingot: return "Iron Ingot"
        case .T3_ingot: return "Darksteel Ingot"
        case .T4_ingot: return "Cobaltite Ingot"
        case .T5_ingot: return "Mithril Ingot"
        case .T6_ingot: return "Obsidian Ingot"
        case .T7_ingot: return "Nacreum Ingot"
        case .T8_ingot: return "Ubronium Ingot"
        case .T9_ingot: return "Mantleborn Ingot"
        case .T10_ingot: return "Novaheart Ingot"
        case .T11_ingot: return "Dragonvein Ingot"

        case .T1_aHead: return "Copper Arrowheads"
        case .T2_aHead: return "Iron Arrowheads"
        case .T3_aHead: return "Darksteel Arrowheads"
        case .T4_aHead: return "Cobaltite Arrowheads"
        case .T5_aHead: return "Mithril Arrowheads"
        case .T6_aHead: return "Obsidian Arrowheads"
        case .T7_aHead: return "Nacreum Arrowheads"
        case .T8_aHead: return "Ubronium Arrowheads"
        case .T9_aHead: return "Mantleborn Arrowheads"
        case .T10_aHead: return "Novaheart Arrowheads"
        case .T11_aHead: return "Dragonvein Arrowheads"
            
        case .T0_pickaxeH: return "Makeshift Pickaxe Head"
        case .T1_pickaxeH: return "Copper Pickaxe Head"
        case .T2_pickaxeH: return "Iron Pickaxe Head"
        case .T3_pickaxeH: return "Darksteel Pickaxe Head"
        case .T4_pickaxeH: return "Cobaltite Pickaxe Head"
        case .T5_pickaxeH: return "Mithril Pickaxe Head"
        case .T6_pickaxeH: return "Obsidian Pickaxe Head"
        case .T7_pickaxeH: return "Nacreum Pickaxe Head"
        case .T8_pickaxeH: return "Ubronium Pickaxe Head"
        case .T9_pickaxeH: return "Mantleborn Pickaxe Head"
        case .T10_pickaxeH: return "Novaheart Pickaxe Head"
        case .T11_pickaxeH: return "Dragonvein Pickaxe Head"
            
        case .T0_axeHead: return "Makeshift Axe Head"
        case .T1_axeHead: return "Copper Axe Head"
        case .T2_axeHead: return "Iron Axe Head"
        case .T3_axeHead: return "Darksteel Axe Head"
        case .T4_axeHead: return "Cobaltite Axe Head"
        case .T5_axeHead: return "Mithril Axe Head"
        case .T6_axeHead: return "Obsidian Axe Head"
        case .T7_axeHead: return "Nacreum Axe Head"
        case .T8_axeHead: return "Ubronium Axe Head"
        case .T9_axeHead: return "Mantleborn Axe Head"
        case .T10_axeHead: return "Novaheart Axe Head"
        case .T11_axeHead: return "Dragonvein Axe Head"
            
        case .T0_knifeBlade: return "Makeshift Knife Blade"
        case .T1_knifeBlade: return "Copper Knife Blade"
        case .T2_knifeBlade: return "Iron Knife Blade"
        case .T3_knifeBlade: return "Darksteel Knife Blade"
        case .T4_knifeBlade: return "Cobaltite Knife Blade"
        case .T5_knifeBlade: return "Mithril Knife Blade"
        case .T6_knifeBlade: return "Obsidian Knife Blade"
        case .T7_knifeBlade: return "Nacreum Knife Blade"
        case .T8_knifeBlade: return "Ubronium Knife Blade"
        case .T9_knifeBlade: return "Mantleborn Knife Blade"
        case .T10_knifeBlade: return "Novaheart Knife Blade"
        case .T11_knifeBlade: return "Dragonvein Knife Blade"
            
    // Carpentry Components
        case .T0_knifeHandle: return "Makeshift Knife Handle"
        case .T1_knifeHandle: return "Willow Knife Handle"
        case .T2_knifeHandle: return "Birch Knife Handle"
        case .T3_knifeHandle: return "Walnut Knife Handle"
        case .T4_knifeHandle: return "Black Cherry Knife Handle"
        case .T5_knifeHandle: return "Lignum Vitae Knife Handle"
        case .T6_knifeHandle: return "Red Oak Knife Handle"
        case .T7_knifeHandle: return "Obsidianheart Knife Handle"
        case .T8_knifeHandle: return "Silvershard Knife Handle"
        case .T9_knifeHandle: return "Ebony Wood Knife Handle"
        case .T10_knifeHandle: return "Starbloom Oak Knife Handle"
        case .T11_knifeHandle: return "Aetherbloom Knife Handle"
            
        case .T0_axeHandle: return "Makeshift Axe Handle"
        case .T1_axeHandle: return "Willow Axe Handle"
        case .T2_axeHandle: return "Birch Axe Handle"
        case .T3_axeHandle: return "Walnut Axe Handle"
        case .T4_axeHandle: return "Black Cherry Axe Handle"
        case .T5_axeHandle: return "Lignum Vitae Axe Handle"
        case .T6_axeHandle: return "Red Oak Axe Handle"
        case .T7_axeHandle: return "Obsidianheart Axe Handle"
        case .T8_axeHandle: return "Silvershard Axe Handle"
        case .T9_axeHandle: return "Ebony Wood Axe Handle"
        case .T10_axeHandle: return "Starbloom Oak Axe Handle"
        case .T11_axeHandle: return "Aetherbloom Axe Handle"
            
        case .T1_plank: return "Willow Plank"
        case .T2_plank: return "Birch Plank"
        case .T3_plank: return "Walnut Plank"
        case .T4_plank: return "Black Cherry Plank"
        case .T5_plank: return "Lignum Vitae Plank"
        case .T6_plank: return "Red Oak Plank"
        case .T7_plank: return "Obsidianheart Plank"
        case .T8_plank: return "Silvershard Plank"
        case .T9_plank: return "Ebony Plank"
        case .T10_plank: return "Starbloom Oak Plank"
        case .T11_plank: return "Aetherbloom Plank"
            
    // Fletching Componenets
        case .T1_shaft: return "Willow Shaft"
        case .T2_shaft: return "Birch Shaft"
        case .T3_shaft: return "Walnut Shaft"
        case .T4_shaft: return "Black Cherry Shaft"
        case .T5_shaft: return "Lignum Vitae Shaft"
        case .T6_shaft: return "Red Oak Shaft"
        case .T7_shaft: return "Obsidianheart Shaft"
        case .T8_shaft: return "Silvershard Shaft"
        case .T9_shaft: return "Ebony Shaft"
        case .T10_shaft: return "Starbloom Shaft"
        case .T11_shaft: return "Aetherbloom Shaft"
            
        case .T1_uBow: return "Unstrung Willow Bow"
        case .T2_uBow: return "Unstrung Birch Bow"
        case .T3_uBow: return "Unstrung Walnut Bow"
        case .T4_uBow: return "Unstrung Black Cherry Bow"
        case .T5_uBow: return "Unstrung Lignum Vitae Bow"
        case .T6_uBow: return "Unstrung Red Oak Bow"
        case .T7_uBow: return "Unstrung Obsidianheart Bow"
        case .T8_uBow: return "Unstrung Silvershard Bow"
        case .T9_uBow: return "Unstrung Ebony Bow"
        case .T10_uBow: return "Unstrung Starbloom Bow"
        case .T11_uBow: return "Unstrung Aetherbloom Bow"
            
    // Leathermaking Components
        case .bowstring: return "Bowstring"
            
        case .T1_leather: return "Tanned Hare Leather"
        case .T2_leather: return "Tanned Deer Leather"
        case .T3_leather: return "Tanned Lynx Leather"
        case .T4_leather: return "Tanned Boar Leather"
        case .T5_leather: return "Tanned Mist Elk Leather"
        case .T6_leather: return "Tanned Dire Wolf Leather"
        case .T7_leather: return "Tanned Shadow Panther Leather"
        case .T8_leather: return "Tanned Kodiak Bear Leather"
        case .T9_leather: return "Tanned Sabretooth Tiger Leather"
        case .T10_leather: return "Treated Storm Basalisk Leather"
        case .T11_leather: return "Treated Fire Drake Leather"
        
    // Jewel Crafting
        case .T1_cutGemstone: return "Cut Sapphire Gemstone"
        case .T2_cutGemstone: return "Cut Emerald Gemstone"
        case .T3_cutGemstone: return "Cut Ruby Gemstone"
        case .T4_cutGemstone: return "Cut Diamond Gemstone"
        case .T5_cutGemstone: return "Cut Onyx Gemstone"
        case .T6_cutGemstone: return "Cut Dragonstone Gemstone"
            
    // Alchemical Componenets
        case .lesserHerbQuintessence: return "Lesser Herb Quintessence"
        case .lesserWoodQuintessence: return "Lesser Wood Quintessence"
        case .lesserStoneQuintessence: return "Lesser Stone Quintessence"
        }
    }
    
    var description: String {
        switch self {
    // Apothecary Components
        case .T1_plantComp: return "Crushed Basil Leaf"
        case .T2_plantComp: return "Muddled Dandelion Petal"
        case .T3_plantComp: return "Ground Lavendar"
        case .T4_plantComp: return "Crushed Rosehip Cluster"
        case .T5_plantComp: return "Ground Watermelon Leaf"
        case .T6_plantComp: return "Muddled Sunpetal Flower"
        case .T7_plantComp: return "Minced Frostcap Mushroom"
        case .T8_plantComp: return "Ground Bloodthorn Berry"
        case .T9_plantComp: return "Crushed Shadow Lily Petals"
        case .T10_plantComp: return "Crushed Starbloom Lily Petals"
        case .T11_plantComp: return "Minced Dragonvine Spores"
            
    // Smithing Components
        case .buckle: return "Buckle"
            
        case .silverIngot: return "Silver Ingot"
        case .goldIngot: return "Gold Ingot"
        case .platinumIngot: return "Platinum Ingot"
            
        case .T1_ingot: return "Copper Ingot"
        case .T2_ingot: return "Iron Ingot"
        case .T3_ingot: return "Darksteel Ingot"
        case .T4_ingot: return "Cobaltite Ingot"
        case .T5_ingot: return "Mithril Ingot"
        case .T6_ingot: return "Obsidian Ingot"
        case .T7_ingot: return "Nacreum Ingot"
        case .T8_ingot: return "Ubronium Ingot"
        case .T9_ingot: return "Mantleborn Ingot"
        case .T10_ingot: return "Novaheart Ingot"
        case .T11_ingot: return "Dragonvein Ingot"
            
        case .T1_aHead: return "Copper Arrowheads"
        case .T2_aHead: return "Iron Arrowheads"
        case .T3_aHead: return "Darksteel Arrowheads"
        case .T4_aHead: return "Cobaltite Arrowheads"
        case .T5_aHead: return "Mithril Arrowheads"
        case .T6_aHead: return "Obsidian Arrowheads"
        case .T7_aHead: return "Nacreum Arrowheads"
        case .T8_aHead: return "Ubronium Arrowheads"
        case .T9_aHead: return "Mantleborn Arrowheads"
        case .T10_aHead: return "Novaheart Arrowheads"
        case .T11_aHead: return "Dragonvein Arrowheads"
            
        case .T0_pickaxeH: return "Makeshift Pickaxe Head"
        case .T1_pickaxeH: return "Copper Pickaxe Head"
        case .T2_pickaxeH: return "Iron Pickaxe Head"
        case .T3_pickaxeH: return "Darksteel Pickaxe Head"
        case .T4_pickaxeH: return "Cobaltite Pickaxe Head"
        case .T5_pickaxeH: return "Mithril Pickaxe Head"
        case .T6_pickaxeH: return "Obsidian Pickaxe Head"
        case .T7_pickaxeH: return "Nacreum Pickaxe Head"
        case .T8_pickaxeH: return "Ubronium Pickaxe Head"
        case .T9_pickaxeH: return "Mantleborn Pickaxe Head"
        case .T10_pickaxeH: return "Novaheart Pickaxe Head"
        case .T11_pickaxeH: return "Dragonvein Pickaxe Head"
            
        case .T0_axeHead: return "Makeshift Axe Head"
        case .T1_axeHead: return "Copper Axe Head"
        case .T2_axeHead: return "Iron Axe Head"
        case .T3_axeHead: return "Darksteel Axe Head"
        case .T4_axeHead: return "Cobaltite Axe Head"
        case .T5_axeHead: return "Mithril Axe Head"
        case .T6_axeHead: return "Obsidian Axe Head"
        case .T7_axeHead: return "Nacreum Axe Head"
        case .T8_axeHead: return "Ubronium Axe Head"
        case .T9_axeHead: return "Mantleborn Axe Head"
        case .T10_axeHead: return "Novaheart Axe Head"
        case .T11_axeHead: return "Dragonvein Axe Head"
            
        case .T0_knifeBlade: return "Makeshift Knife Blade"
        case .T1_knifeBlade: return "Copper Knife Blade"
        case .T2_knifeBlade: return "Iron Knife Blade"
        case .T3_knifeBlade: return "Darksteel Knife Blade"
        case .T4_knifeBlade: return "Cobaltite Knife Blade"
        case .T5_knifeBlade: return "Mithril Knife Blade"
        case .T6_knifeBlade: return "Obsidian Knife Blade"
        case .T7_knifeBlade: return "Nacreum Knife Blade"
        case .T8_knifeBlade: return "Ubronium Knife Blade"
        case .T9_knifeBlade: return "Mantleborn Knife Blade"
        case .T10_knifeBlade: return "Novaheart Knife Blade"
        case .T11_knifeBlade: return "Dragonvein Knife Blade"
            
    // Carpentry Components
        case .T0_knifeHandle: return "Makeshift Knife Handle"
        case .T1_knifeHandle: return "Willow Knife Handle"
        case .T2_knifeHandle: return "Birch Knife Handle"
        case .T3_knifeHandle: return "Walnut Knife Handle"
        case .T4_knifeHandle: return "Black Cherry Knife Handle"
        case .T5_knifeHandle: return "Lignum Vitae Knife Handle"
        case .T6_knifeHandle: return "Red Oak Knife Handle"
        case .T7_knifeHandle: return "Obsidianheart Knife Handle"
        case .T8_knifeHandle: return "Silvershard Knife Handle"
        case .T9_knifeHandle: return "Ebony Wood Knife Handle"
        case .T10_knifeHandle: return "Starbloom Oak Knife Handle"
        case .T11_knifeHandle: return "Aetherbloom Knife Handle"
            
        case .T0_axeHandle: return "Makeshift Axe Handle"
        case .T1_axeHandle: return "Willow Axe Handle"
        case .T2_axeHandle: return "Birch Axe Handle"
        case .T3_axeHandle: return "Walnut Axe Handle"
        case .T4_axeHandle: return "Black Cherry Axe Handle"
        case .T5_axeHandle: return "Lignum Vitae Axe Handle"
        case .T6_axeHandle: return "Red Oak Axe Handle"
        case .T7_axeHandle: return "Obsidianheart Axe Handle"
        case .T8_axeHandle: return "Silvershard Axe Handle"
        case .T9_axeHandle: return "Ebony Wood Axe Handle"
        case .T10_axeHandle: return "Starbloom Oak Axe Handle"
        case .T11_axeHandle: return "Aetherbloom Axe Handle"
            
        case .T1_plank: return "Willow Plank"
        case .T2_plank: return "Birch Plank"
        case .T3_plank: return "Walnut Plank"
        case .T4_plank: return "Black Cherry Plank"
        case .T5_plank: return "Lignum Vitae Plank"
        case .T6_plank: return "Red Oak Plank"
        case .T7_plank: return "Obsidianheart Plank"
        case .T8_plank: return "Silvershard Plank"
        case .T9_plank: return "Ebony Plank"
        case .T10_plank: return "Starbloom Oak Plank"
        case .T11_plank: return "Aetherbloom Plank"
            
    // Fletching Componenets
        case .T1_shaft: return "Willow Shaft"
        case .T2_shaft: return "Birch Shaft"
        case .T3_shaft: return "Walnut Shaft"
        case .T4_shaft: return "Black Cherry Shaft"
        case .T5_shaft: return "Lignum Vitae Shaft"
        case .T6_shaft: return "Red Oak Shaft"
        case .T7_shaft: return "Obsidianheart Shaft"
        case .T8_shaft: return "Silvershard Shaft"
        case .T9_shaft: return "Ebony Shaft"
        case .T10_shaft: return "Starbloom Shaft"
        case .T11_shaft: return "Aetherbloom Shaft"
            
        case .T1_uBow: return "Unstrung Willow Bow"
        case .T2_uBow: return "Unstrung Birch Bow"
        case .T3_uBow: return "Unstrung Walnut Bow"
        case .T4_uBow: return "Unstrung Black Cherry Bow"
        case .T5_uBow: return "Unstrung Lignum Vitae Bow"
        case .T6_uBow: return "Unstrung Red Oak Bow"
        case .T7_uBow: return "Unstrung Obsidianheart Bow"
        case .T8_uBow: return "Unstrung Silvershard Bow"
        case .T9_uBow: return "Unstrung Ebony Bow"
        case .T10_uBow: return "Unstrung Starbloom Bow"
        case .T11_uBow: return "Unstrung Aetherbloom Bow"
            
    // Leathermaking Components
//        case .tannedLeather: return "Small section of flexible leather, processed from Rawhide."
        case .bowstring: return "Bowstring"
            
        case .T1_leather: return "Tanned Hare Leather"
        case .T2_leather: return "Tanned Deer Leather"
        case .T3_leather: return "Tanned Lynx Leather"
        case .T4_leather: return "Tanned Boar Leather"
        case .T5_leather: return "Tanned Mist Elk Leather"
        case .T6_leather: return "Tanned Dire Wolf Leather"
        case .T7_leather: return "Tanned Shadow Panther Leather"
        case .T8_leather: return "Tanned Kodiak Bear Leather"
        case .T9_leather: return "Tanned Sabretooth Tiger Leather"
        case .T10_leather: return "Treated Storm Basalisk Leather"
        case .T11_leather: return "Treated Fire Drake Leather"
            
    // Alchemical Componenets
        case .lesserHerbQuintessence: return "A substitute component used in basic potions."
        case .lesserWoodQuintessence: return "A substitute component used in woodworking."
        case .lesserStoneQuintessence: return "A substitute component used in smithing."
            
    // Jewel Crafting
        case .T1_cutGemstone: return "Sapphire Gemstone"
        case .T2_cutGemstone: return "Emerald Gemstone"
        case .T3_cutGemstone: return "Ruby Gemstone"
        case .T4_cutGemstone: return "Diamond Gemstone"
        case .T5_cutGemstone: return "Onyx Gemstone"
        case .T6_cutGemstone: return "Dragonstone Gemstone"
            
        }
    }
    
    var iconAssetName: String {
        switch self {
    // Herblore Components
        case .T1_plantComp: return "T1_plantComp"
        case .T2_plantComp: return "T2_plantComp"
        case .T3_plantComp: return "T3_plantComp"
        case .T4_plantComp: return "T4_plantComp"
        case .T5_plantComp: return "T5_plantComp"
        case .T6_plantComp: return "T6_plantComp"
        case .T7_plantComp: return "T7_plantComp"
        case .T8_plantComp: return "T8_plantComp"
        case .T9_plantComp: return "T9_plantComp"
        case .T10_plantComp: return "T10_plantComp"
        case .T11_plantComp: return "T11_plantComp"
            
    // Leathermaking Components
        case .bowstring: return "bowstring"
        case .T1_leather: return "T1_leather"
        case .T2_leather: return "T2_leather"
        case .T3_leather: return "T3_leather"
        case .T4_leather: return "T4_leather"
        case .T5_leather: return "T5_leather"
        case .T6_leather: return "T6_leather"
        case .T7_leather: return "T7_leather"
        case .T8_leather: return "T8_leather"
        case .T9_leather: return "T9_leather"
        case .T10_leather: return "T10_leather"
        case .T11_leather: return "T11_leather"
            
    // Smithing Components
        case .buckle: return "buckle"
            
        case .silverIngot: return "silver_ingot"
        case .goldIngot: return "gold_ingot"
        case .platinumIngot: return "platinum_ingot"
            
        case .T1_ingot: return "T1_ingot"
        case .T2_ingot: return "T2_ingot"
        case .T3_ingot: return "T3_ingot"
        case .T4_ingot: return "T4_ingot"
        case .T5_ingot: return "T5_ingot"
        case .T6_ingot: return "T6_ingot"
        case .T7_ingot: return "T7_ingot"
        case .T8_ingot: return "T8_ingot"
        case .T9_ingot: return "T9_ingot"
        case .T10_ingot: return "T10_ingot"
        case .T11_ingot: return "T11_ingot"
            
        case .T0_pickaxeH: return "T0_pickaxeH"
        case .T1_pickaxeH: return "T1_pickaxeH"
        case .T2_pickaxeH: return "T2_pickaxeH"
        case .T3_pickaxeH: return "T3_pickaxeH"
        case .T4_pickaxeH: return "T4_pickaxeH"
        case .T5_pickaxeH: return "T5_pickaxeH"
        case .T6_pickaxeH: return "T6_pickaxeH"
        case .T7_pickaxeH: return "T7_pickaxeH"
        case .T8_pickaxeH: return "T8_pickaxeH"
        case .T9_pickaxeH: return "T9_pickaxeH"
        case .T10_pickaxeH: return "T10_pickaxeH"
        case .T11_pickaxeH: return "T11_pickaxeH"
            
        case .T0_axeHead: return "T0_axeH"
        case .T1_axeHead: return "T1_axeH"
        case .T2_axeHead: return "T2_axeH"
        case .T3_axeHead: return "T3_axeH"
        case .T4_axeHead: return "T4_axeH"
        case .T5_axeHead: return "T5_axeH"
        case .T6_axeHead: return "T6_axeH"
        case .T7_axeHead: return "T7_axeH"
        case .T8_axeHead: return "T8_axeH"
        case .T9_axeHead: return "T9_axeH"
        case .T10_axeHead: return "T10_axeH"
        case .T11_axeHead: return "T11_axeH"
            
        case .T1_aHead: return "T1_aHeads"
        case .T2_aHead: return "T2_aHeads"
        case .T3_aHead: return "T3_aHeads"
        case .T4_aHead: return "T4_aHeads"
        case .T5_aHead: return "T5_aHeads"
        case .T6_aHead: return "T6_aHeads"
        case .T7_aHead: return "T7_aHeads"
        case .T8_aHead: return "T8_aHeads"
        case .T9_aHead: return "T9_aHeads"
        case .T10_aHead: return "T10_aHeads"
        case .T11_aHead: return "T11_aHeads"
            
        case .T0_knifeBlade: return "T0_knifeB"
        case .T1_knifeBlade: return "T1_knifeB"
        case .T2_knifeBlade: return "T2_knifeB"
        case .T3_knifeBlade: return "T3_knifeB"
        case .T4_knifeBlade: return "T4_knifeB"
        case .T5_knifeBlade: return "T5_knifeB"
        case .T6_knifeBlade: return "T6_knifeB"
        case .T7_knifeBlade: return "T7_knifeB"
        case .T8_knifeBlade: return "T8_knifeB"
        case .T9_knifeBlade: return "T9_knifeB"
        case .T10_knifeBlade: return "T10_knifeB"
        case .T11_knifeBlade: return "T11_knifeB"
            
    // Carpentry Components
        case .T0_knifeHandle: return "T0_kHandle"
        case .T1_knifeHandle: return "T1_kHandle"
        case .T2_knifeHandle: return "T2_kHandle"
        case .T3_knifeHandle: return "T3_kHandle"
        case .T4_knifeHandle: return "T4_kHandle"
        case .T5_knifeHandle: return "T5_kHandle"
        case .T6_knifeHandle: return "T6_kHandle"
        case .T7_knifeHandle: return "T7_kHandle"
        case .T8_knifeHandle: return "T8_kHandle"
        case .T9_knifeHandle: return "T9_kHandle"
        case .T10_knifeHandle: return "T10_kHandle"
        case .T11_knifeHandle: return "T11_kHandle"
            
        case .T0_axeHandle: return "T0_axeHandle"
        case .T1_axeHandle: return "T1_axeHandle"
        case .T2_axeHandle: return "T2_axeHandle"
        case .T3_axeHandle: return "T3_axeHandle"
        case .T4_axeHandle: return "T4_axeHandle"
        case .T5_axeHandle: return "T5_axeHandle"
        case .T6_axeHandle: return "T6_axeHandle"
        case .T7_axeHandle: return "T7_axeHandle"
        case .T8_axeHandle: return "T8_axeHandle"
        case .T9_axeHandle: return "T9_axeHandle"
        case .T10_axeHandle: return "T10_axeHandle"
        case .T11_axeHandle: return "T11_axeHandle"
            
        case .T1_plank: return "T1_plank"
        case .T2_plank: return "T2_plank"
        case .T3_plank: return "T3_plank"
        case .T4_plank: return "T4_plank"
        case .T5_plank: return "T5_plank"
        case .T6_plank: return "T6_plank"
        case .T7_plank: return "T7_plank"
        case .T8_plank: return "T8_plank"
        case .T9_plank: return "T9_plank"
        case .T10_plank: return "T10_plank"
        case .T11_plank: return "T11_plank"
            
    // Fletching Componenets
        case .T1_shaft: return "T1_shaft"
        case .T2_shaft: return "T2_shaft"
        case .T3_shaft: return "T3_shaft"
        case .T4_shaft: return "T4_shaft"
        case .T5_shaft: return "T5_shaft"
        case .T6_shaft: return "T6_shaft"
        case .T7_shaft: return "T7_shaft"
        case .T8_shaft: return "T8_shaft"
        case .T9_shaft: return "T9_shaft"
        case .T10_shaft: return "T10_shaft"
        case .T11_shaft: return "T11_shaft"
            
        case .T1_uBow: return "T1_uBow"
        case .T2_uBow: return "T2_uBow"
        case .T3_uBow: return "T3_uBow"
        case .T4_uBow: return "T4_uBow"
        case .T5_uBow: return "T5_uBow"
        case .T6_uBow: return "T6_uBow"
        case .T7_uBow: return "T7_uBow"
        case .T8_uBow: return "T8_uBow"
        case .T9_uBow: return "T9_uBow"
        case .T10_uBow: return "T10_uBow"
        case .T11_uBow: return "T11_uBow"
            
    // Alchemical Components
        case .lesserHerbQuintessence: return "lesser_herb_quintessence"
        case .lesserWoodQuintessence: return "lesser_wood_quintessence"
        case .lesserStoneQuintessence: return "lesser_stone_quintessence"
            
    // Jewel crafting
        case .T1_cutGemstone: return "sapphireCut"
        case .T2_cutGemstone: return "emeraldCut"
        case .T3_cutGemstone: return "rubyCut"
        case .T4_cutGemstone: return "diamondCut"
        case .T5_cutGemstone: return "onyxCut"
        case .T6_cutGemstone: return "dragonstoneCut"
        }
    }
    
    var tier: Int {
            switch self {
            // Tier 0 Components (no hierachy)
            case .buckle, .bowstring, .T0_pickaxeH, .T0_axeHead, .T0_knifeBlade, .T0_axeHandle, .T0_knifeHandle:
                return 0
            // Tier 1 Components (made from T1 resources)
            case .lesserStoneQuintessence, .lesserWoodQuintessence, .lesserHerbQuintessence, .T1_plantComp, .T1_leather, .T1_plank, .T1_uBow, .T1_knifeBlade, .T1_knifeHandle, .T1_axeHead, .T1_pickaxeH, .T1_shaft, .T1_aHead, .T1_axeHandle, .T1_ingot, .T1_cutGemstone:
                return 1
                
            // Tier 2 Components (made from T2 resources)
            case  .T2_plantComp, .T2_leather, .T2_plank, .T2_uBow, .T2_knifeBlade, .T2_knifeHandle, .T2_axeHead, .T2_pickaxeH, .T2_shaft, .T2_aHead, .T2_axeHandle, .T2_ingot, .T2_cutGemstone:
                return 2
                
            // Tier 3 Components
            case .T3_plantComp, .T3_leather, .T3_plank, .T3_uBow, .T3_knifeBlade, .T3_knifeHandle, .T3_axeHead, .T3_pickaxeH, .T3_shaft, .T3_aHead, .T3_axeHandle, .T3_ingot, .T3_cutGemstone:
                 return 3
                 
            case .silverIngot, .T4_plantComp, .T4_leather, .T4_plank, .T4_uBow, .T4_knifeBlade, .T4_knifeHandle, .T4_axeHead, .T4_pickaxeH, .T4_shaft, .T4_aHead, .T4_axeHandle, .T4_ingot, .T4_cutGemstone:
                 return 4
                
            case .T5_plantComp, .T5_leather, .T5_plank, .T5_uBow, .T5_knifeBlade, .T5_knifeHandle, .T5_axeHead, .T5_pickaxeH, .T5_shaft, .T5_aHead, .T5_axeHandle, .T5_ingot, .T5_cutGemstone:
                 return 5
                
            case .goldIngot, .T6_plantComp, .T6_leather, .T6_plank, .T6_uBow, .T6_knifeBlade, .T6_knifeHandle, .T6_axeHead, .T6_pickaxeH, .T6_shaft, .T6_aHead, .T6_axeHandle, .T6_ingot, .T6_cutGemstone:
                 return 6
                
            case .T7_plantComp, .T7_leather, .T7_plank, .T7_uBow, .T7_knifeBlade, .T7_knifeHandle, .T7_axeHead, .T7_pickaxeH, .T7_shaft, .T7_aHead, .T7_axeHandle, .T7_ingot:
                 return 7
                
            case .platinumIngot, .T8_plantComp, .T8_leather, .T8_plank, .T8_uBow, .T8_knifeBlade, .T8_knifeHandle, .T8_axeHead, .T8_pickaxeH, .T8_shaft, .T8_aHead, .T8_axeHandle, .T8_ingot:
                 return 8
                
            case .T9_plantComp, .T9_leather, .T9_plank, .T9_uBow, .T9_knifeBlade, .T9_knifeHandle, .T9_axeHead, .T9_pickaxeH, .T9_shaft, .T9_aHead, .T9_axeHandle, .T9_ingot:
                 return 9
                
            case .T10_plantComp, .T10_leather, .T10_plank, .T10_uBow, .T10_knifeBlade, .T10_knifeHandle, .T10_axeHead, .T10_pickaxeH, .T10_shaft, .T10_aHead, .T10_axeHandle, .T10_ingot:
                 return 10
                
            case .T11_plantComp, .T11_leather, .T11_plank, .T11_uBow, .T11_knifeBlade, .T11_knifeHandle, .T11_axeHead, .T11_pickaxeH, .T11_shaft, .T11_aHead, .T11_axeHandle, .T11_ingot:
                 return 11
            }
        }
    
    // A helper to get the required level for a specific skill, using your defined progression.
    func requiredSkillLevel(for skill: SkillType) -> Int {
        // We only calculate a level requirement if the recipe actually grants XP for that skill.
        // Otherwise, we assume it's a Level 1 recipe.
        // We access the recipe property of 'self' to find the skillXP dictionary.
        guard self.recipe?.skillXP?[skill] != nil else {
            return 1
        }
        
        // Apply your specific tier-based progression rules.
        switch self.tier {
        case 0, 1:
            // Tier 0 and Tier 1 components are available at Skill Level 1.
            return 1
        case 2:
            // Tier 2 components are available at Skill Level 5.
            return 5
        default:
            // Tiers 3 and above follow the formula: (Tier - 1) * 5
            // Example: T3 -> (3-1)*5 = 10
            //          T4 -> (4-1)*5 = 15
            return (self.tier - 1) * 5
        }
    }
    
    // Define crafting recipes here or in a separate Recipe manager
    struct Recipe {
        let ingredients: [ResourceType: Int]? // Optional dictionary
        let components: [ComponentType: Int]? // Optional dictionary
        let genericIngredients: [GenericIngredient: Int]?
        let requiredUpgrade: BaseUpgradeType? // Optional required base upgrade for crafting
        let skillXP: [SkillType: Int]? // XP gained for crafting this component

        // Initializer allowing nil for ingredients or components
        init(ingredients: [ResourceType: Int]? = nil,
             components: [ComponentType: Int]? = nil,
             genericIngredients: [GenericIngredient: Int]? = nil,
             requiredUpgrade: BaseUpgradeType?, // Making this non-optional for components from stations
             skillXP: [SkillType: Int]? = nil) {
            self.ingredients = ingredients
            self.components = components
            self.genericIngredients = genericIngredients
            self.requiredUpgrade = requiredUpgrade
            self.skillXP = skillXP
        }
    }
    
    var recipe: Recipe? {
        switch self {
    // ALCHEMY
        case .lesserHerbQuintessence: return Recipe(ingredients: [.T2_herb: 10], requiredUpgrade: .alchemyLab, skillXP: [.alchemy: 5])
        case .lesserWoodQuintessence: return Recipe(ingredients: [.T2_wood: 10], requiredUpgrade: .alchemyLab, skillXP: [.alchemy: 5])
        case .lesserStoneQuintessence: return Recipe(ingredients: [.T2_stone: 10], requiredUpgrade: .alchemyLab, skillXP: [.alchemy: 5])
            
    // LEATHERWORKING
        case .bowstring:
            return Recipe(ingredients: [.T1_hide: 1], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50])
        case .T1_leather:
            return Recipe(ingredients: [.T1_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50])
        case .T2_leather:
            return Recipe(ingredients: [.T2_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 100])
        case .T3_leather:
            return Recipe(ingredients: [.T3_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 175])
        case .T4_leather:
            return Recipe(ingredients: [.T4_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 300])
        case .T5_leather:
            return Recipe(ingredients: [.T5_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 500])
        case .T6_leather:
            return Recipe(ingredients: [.T6_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 800])
        case .T7_leather:
            return Recipe(ingredients: [.T7_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 1300])
        case .T8_leather:
            return Recipe(ingredients: [.T8_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 2000])
        case .T9_leather:
            return Recipe(ingredients: [.T9_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 3000])
        case .T10_leather:
            return Recipe(ingredients: [.T10_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 4500])
        case .T11_leather:
            return Recipe(ingredients: [.T11_hide: 2], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 7000])
            
    // SMITHING
        case .buckle:
            return Recipe(
                    genericIngredients: [.anyStandardIngot: 1], // Requires 1 of ANY standard ingot
                    requiredUpgrade: .basicForge,
                    skillXP: [.smithing: 30]
                )
        case .silverIngot:
            return Recipe(ingredients: [.silverOre: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 100])
        case .goldIngot:
            return Recipe(ingredients: [.goldOre: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 500])
        case .platinumIngot:
            return Recipe(ingredients: [.platinumOre: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 1250])
            
        case .T1_ingot:
            return Recipe(ingredients: [.T1_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 10])
        case .T2_ingot:
            return Recipe(ingredients: [.T2_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 20])
        case .T3_ingot:
            return Recipe(ingredients: [.T3_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 30])
        case .T4_ingot:
            return Recipe(ingredients: [.T4_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 40])
        case .T5_ingot:
            return Recipe(ingredients: [.T5_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 50])
        case .T6_ingot:
            return Recipe(ingredients: [.T6_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 60])
        case .T7_ingot:
            return Recipe(ingredients: [.T7_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 70])
        case .T8_ingot:
            return Recipe(ingredients: [.T8_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 80])
        case .T9_ingot:
            return Recipe(ingredients: [.T9_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 90])
        case .T10_ingot:
            return Recipe(ingredients: [.T10_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 100])
        case .T11_ingot:
            return Recipe(ingredients: [.T11_stone: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 125])
            
        case .T0_axeHead:
            return Recipe(ingredients: [.stone: 3], requiredUpgrade: nil, skillXP: [.smithing: 20])
        case .T1_axeHead:
            return Recipe(components: [.T1_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 30])
        case .T2_axeHead:
            return Recipe(components: [.T2_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 60])
        case .T3_axeHead:
            return Recipe(components: [.T3_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 90])
        case .T4_axeHead:
            return Recipe(components: [.T4_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 120])
        case .T5_axeHead:
            return Recipe(components: [.T5_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 150])
        case .T6_axeHead:
            return Recipe(components: [.T6_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 180])
        case .T7_axeHead:
            return Recipe(components: [.T7_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 210])
        case .T8_axeHead:
            return Recipe(components: [.T8_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 240])
        case .T9_axeHead:
            return Recipe(components: [.T9_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 270])
        case .T10_axeHead:
            return Recipe(components: [.T10_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 300])
        case .T11_axeHead:
            return Recipe(components: [.T11_ingot: 3], requiredUpgrade: .basicForge, skillXP: [.smithing: 360])
        
        case .T0_pickaxeH:
            return Recipe(ingredients: [.stone: 3], requiredUpgrade: nil, skillXP: [.smithing: 20])
        case .T1_pickaxeH:
            return Recipe(components: [.T1_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 40])
        case .T2_pickaxeH:
            return Recipe(components: [.T2_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 80])
        case .T3_pickaxeH:
            return Recipe(components: [.T3_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 120])
        case .T4_pickaxeH:
            return Recipe(components: [.T4_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 160])
        case .T5_pickaxeH:
            return Recipe(components: [.T5_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 200])
        case .T6_pickaxeH:
            return Recipe(components: [.T6_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 240])
        case .T7_pickaxeH:
            return Recipe(components: [.T7_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 280])
        case .T8_pickaxeH:
            return Recipe(components: [.T8_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 320])
        case .T9_pickaxeH:
            return Recipe(components: [.T9_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 360])
        case .T10_pickaxeH:
            return Recipe(components: [.T10_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 400])
        case .T11_pickaxeH:
            return Recipe(components: [.T11_ingot: 4], requiredUpgrade: .basicForge, skillXP: [.smithing: 480])
            
        case .T0_knifeBlade:
            return Recipe(ingredients: [.stone: 2], requiredUpgrade: nil, skillXP: [.smithing: 15])
        case .T1_knifeBlade:
            return Recipe(components: [.T1_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 20])
        case .T2_knifeBlade:
            return Recipe(components: [.T2_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 40])
        case .T3_knifeBlade:
            return Recipe(components: [.T3_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 60])
        case .T4_knifeBlade:
            return Recipe(components: [.T4_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 80])
        case .T5_knifeBlade:
            return Recipe(components: [.T5_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 100])
        case .T6_knifeBlade:
            return Recipe(components: [.T6_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 120])
        case .T7_knifeBlade:
            return Recipe(components: [.T7_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 140])
        case .T8_knifeBlade:
            return Recipe(components: [.T8_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 160])
        case .T9_knifeBlade:
            return Recipe(components: [.T9_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 180])
        case .T10_knifeBlade:
            return Recipe(components: [.T10_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 200])
        case .T11_knifeBlade:
            return Recipe(components: [.T11_ingot: 2], requiredUpgrade: .basicForge, skillXP: [.smithing: 240])
            
        case .T1_aHead:
            return Recipe(components: [.T1_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 8])
        case .T2_aHead:
            return Recipe(components: [.T2_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 16])
        case .T3_aHead:
            return Recipe(components: [.T3_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 24])
        case .T4_aHead:
            return Recipe(components: [.T4_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 32])
        case .T5_aHead:
            return Recipe(components: [.T5_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 40])
        case .T6_aHead:
            return Recipe(components: [.T6_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 48])
        case .T7_aHead:
            return Recipe(components: [.T7_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 56])
        case .T8_aHead:
            return Recipe(components: [.T8_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 64])
        case .T9_aHead:
            return Recipe(components: [.T9_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 72])
        case .T10_aHead:
            return Recipe(components: [.T10_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 80])
        case .T11_aHead:
            return Recipe(components: [.T11_ingot: 1], requiredUpgrade: .basicForge, skillXP: [.smithing: 88])
        
    // CARPENTRY
        case .T0_axeHandle:
            return Recipe(ingredients: [.T0_wood: 3], requiredUpgrade: nil, skillXP: [.carpentry: 20])
        case .T0_knifeHandle:
            return Recipe(ingredients: [.T0_wood: 2], requiredUpgrade: nil, skillXP: [.carpentry: 15])
        case .T1_plank:
            return Recipe(ingredients: [.T1_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T1_knifeHandle:
            return Recipe(components: [.T1_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T1_axeHandle:
            return Recipe(components: [.T1_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T2_plank:
            return Recipe(ingredients: [.T2_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T2_knifeHandle:
            return Recipe(components: [.T2_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T2_axeHandle:
            return Recipe(components: [.T2_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T3_plank:
            return Recipe(ingredients: [.T3_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T3_knifeHandle:
            return Recipe(components: [.T3_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T3_axeHandle:
            return Recipe(components: [.T3_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T4_plank:
            return Recipe(ingredients: [.T4_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T4_knifeHandle:
            return Recipe(components: [.T4_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T4_axeHandle:
            return Recipe(components: [.T4_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T5_plank:
            return Recipe(ingredients: [.T5_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T5_knifeHandle:
            return Recipe(components: [.T5_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T5_axeHandle:
            return Recipe(components: [.T5_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T6_plank:
            return Recipe(ingredients: [.T6_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T6_knifeHandle:
            return Recipe(components: [.T6_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T6_axeHandle:
            return Recipe(components: [.T6_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T7_plank:
            return Recipe(ingredients: [.T7_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T7_knifeHandle:
            return Recipe(components: [.T7_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T7_axeHandle:
            return Recipe(components: [.T7_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T8_plank:
            return Recipe(ingredients: [.T8_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T8_knifeHandle:
            return Recipe(components: [.T8_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T8_axeHandle:
            return Recipe(components: [.T8_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T9_plank:
            return Recipe(ingredients: [.T9_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T9_knifeHandle:
            return Recipe(components: [.T9_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T9_axeHandle:
            return Recipe(components: [.T9_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T10_plank:
            return Recipe(ingredients: [.T10_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T10_knifeHandle:
            return Recipe(components: [.T10_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T10_axeHandle:
            return Recipe(components: [.T10_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T11_plank:
            return Recipe(ingredients: [.T11_wood: 3], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 5])
        case .T11_knifeHandle:
            return Recipe(components: [.T11_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
        case .T11_axeHandle:
            return Recipe(components: [.T11_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 8])
            
    // FLETCHING
        case .T1_shaft:
            return Recipe(ingredients: [.T1_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 3, .fletching: 6])
        case .T2_shaft:
            return Recipe(ingredients: [.T2_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 6, .fletching: 12])
        case .T3_shaft:
            return Recipe(ingredients: [.T3_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 9, .fletching: 18])
        case .T4_shaft:
            return Recipe(ingredients: [.T4_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 12, .fletching: 24])
        case .T5_shaft:
            return Recipe(ingredients: [.T5_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 15, .fletching: 30])
        case .T6_shaft:
            return Recipe(ingredients: [.T6_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 18, .fletching: 36])
        case .T7_shaft:
            return Recipe(ingredients: [.T7_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 21, .fletching: 42])
        case .T8_shaft:
            return Recipe(ingredients: [.T8_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 24, .fletching: 48])
        case .T9_shaft:
            return Recipe(ingredients: [.T9_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 27, .fletching: 54])
        case .T10_shaft:
            return Recipe(ingredients: [.T10_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 30, .fletching: 60])
        case .T11_shaft:
            return Recipe(ingredients: [.T11_wood: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 33, .fletching: 66])
        case .T1_uBow:
            return Recipe(components: [.T1_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 10, .fletching: 10])
        case .T2_uBow:
            return Recipe(components: [.T2_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 20, .fletching: 20])
        case .T3_uBow:
            return Recipe(components: [.T3_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 30, .fletching: 30])
        case .T4_uBow:
            return Recipe(components: [.T4_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 40, .fletching: 40])
        case .T5_uBow:
            return Recipe(components: [.T5_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 50, .fletching: 50])
        case .T6_uBow:
            return Recipe(components: [.T6_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 60, .fletching: 60])
        case .T7_uBow:
            return Recipe(components: [.T7_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 70, .fletching: 70])
        case .T8_uBow:
            return Recipe(components: [.T8_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 80, .fletching: 80])
        case .T9_uBow:
            return Recipe(components: [.T9_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 90, .fletching: 90])
        case .T10_uBow:
            return Recipe(components: [.T10_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 100, .fletching: 100])
        case .T11_uBow:
            return Recipe(components: [.T11_plank: 2], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 110, .fletching: 110])
            
    // JEWELCRAFTING
        case .T1_cutGemstone:
            return Recipe(ingredients: [.T1_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 10])
        case .T2_cutGemstone:
            return Recipe(ingredients: [.T2_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 20])
        case .T3_cutGemstone:
            return Recipe(ingredients: [.T3_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 35])
        case .T4_cutGemstone:
            return Recipe(ingredients: [.T4_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 75])
        case .T5_cutGemstone:
            return Recipe(ingredients: [.T5_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 125])
        case .T6_cutGemstone:
            return Recipe(ingredients: [.T6_gemstone: 1], requiredUpgrade: .jewelCraftingWorkshop, skillXP: [.jewelcrafting: 200])
            
    // HERBLORE
        case .T1_plantComp:
            return Recipe(ingredients: [.T1_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 10])
        case .T2_plantComp:
            return Recipe(ingredients: [.T2_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 20])
        case .T3_plantComp:
            return Recipe(ingredients: [.T3_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 30])
        case .T4_plantComp:
            return Recipe(ingredients: [.T4_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 40])
        case .T5_plantComp:
            return Recipe(ingredients: [.T5_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 50])
        case .T6_plantComp:
            return Recipe(ingredients: [.T6_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 60])
        case .T7_plantComp:
            return Recipe(ingredients: [.T7_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 70])
        case .T8_plantComp:
            return Recipe(ingredients: [.T8_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 80])
        case .T9_plantComp:
            return Recipe(ingredients: [.T9_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 90])
        case .T10_plantComp:
            return Recipe(ingredients: [.T10_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 100])
        case .T11_plantComp:
            return Recipe(ingredients: [.T11_herb: 3], requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 125])
        }
    }
    
    // Amount crafted per recipe (for stackable items like arrows)
    var craftYield: Int {
        switch self {
        case .T1_aHead: return 10 // Crafting once = 10 arrow heads
        case .T2_aHead: return 10
        case .T3_aHead: return 10
        case .T4_aHead: return 10
        case .T5_aHead: return 10
        case .T6_aHead: return 10
        case .T7_aHead: return 10
        case .T8_aHead: return 10
        case .T9_aHead: return 10
        case .T10_aHead: return 10
        case .T11_aHead: return 10
        default: return 1
        }
    }
    
}
// Enum for Base Upgrade Types (to be used in recipes and GameManager)
enum BaseUpgradeType: String, Codable, CaseIterable, Identifiable {
    case basicForge
    case tanningRack
    case scoutsQuarters
    case apothecaryStand
    case basicStorehouse
    case woodworkingShop
    case garden
    case alchemyLab
    case watchtower
    case aviary
    case jewelCraftingWorkshop
    case fletchingWorkshop
    // Add future upgrades here: apothecary, woodshop, etc.

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .basicForge: return "Basic Forge"
        case .tanningRack: return "Tanning Rack"
        case .scoutsQuarters: return "Scouts' Quarters"
        case .apothecaryStand: return "Apothecary Stand"
        case .basicStorehouse: return "Basic Storehouse"
        case .woodworkingShop: return "Woodworking Shop"
        case .garden: return "Garden"
        case .alchemyLab: return "Alchemy Lab"
        case .watchtower: return "Watchtower"
        case .aviary: return "Aviary"
        case .jewelCraftingWorkshop: return "Jewel Crafting Workshop"
        case .fletchingWorkshop: return "Fletching Workshop"
        }
    }
}
