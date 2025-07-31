import Foundation
import SwiftUI // For potential display properties later

// Enum for different types of craftable items (tools, equipment, consumables etc.)
enum ItemType: String, CaseIterable, Codable, Identifiable {
// Tools
    case T0_pickaxe, T0_axe, T0_huntingKnife
    case T1_axe, T1_pickaxe, T1_huntingKnife
    case T2_axe, T2_pickaxe, T2_huntingKnife
    case T3_axe, T3_pickaxe, T3_huntingKnife
    case T4_axe, T4_pickaxe, T4_huntingKnife
    case T5_axe, T5_pickaxe, T5_huntingKnife
    case T6_axe, T6_pickaxe, T6_huntingKnife
    case T7_axe, T7_pickaxe, T7_huntingKnife
    case T8_axe, T8_pickaxe, T8_huntingKnife
    case T9_axe, T9_pickaxe, T9_huntingKnife
    case T10_axe, T10_pickaxe, T10_huntingKnife
    case T11_axe, T11_pickaxe, T11_huntingKnife
// Gear/Utility
    case whetstone
    
    case T1_backpack, T1_herbSatchel
    case T2_backpack, T2_herbSatchel
    case T3_backpack, T3_herbSatchel
    case T4_backpack, T4_herbSatchel
    case T5_backpack, T5_herbSatchel
    case T6_backpack
// Potions (Consumables)
    case T1_potion
    case T2_potion
    case T3_potion
    case T4_potion
    case T5_potion
    case T6_potion
// Pet treats
    case basicPetTreat
    case gourmetPetTreat
// Hunting
    case T1_bow
    case T2_bow
    case T3_bow
    case T4_bow
    case T5_bow
    case T6_bow
    case T7_bow
    case T8_bow
    case T9_bow
    case T10_bow
    case T11_bow
    
    case T1_arrow
    case T2_arrow
    case T3_arrow
    case T4_arrow
    case T5_arrow
    case T6_arrow
    case T7_arrow
    case T8_arrow
    case T9_arrow
    case T10_arrow
    case T11_arrow
// Jewelcrafting
    case T1_ring, T1_necklace
    case T2_ring, T2_necklace
    case T3_ring, T3_necklace
    case T4_ring, T4_necklace
    case T5_ring, T5_necklace
    case T6_ring, T6_necklace
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
    // Tools
        case .T0_axe: return "Makeshift Woodcutting Axe"
        case .T0_pickaxe: return "Makeshift Pickaxe"
        case .T0_huntingKnife: return "Makeshift Hunting Knife"
        case .T1_axe: return "Copper Axe"
        case .T1_pickaxe: return "Copper Pickaxe"
        case .T1_huntingKnife: return "Copper Hunting Knife"
        case .T2_axe: return "Iron Axe"
        case .T2_pickaxe: return "Iron Pickaxe"
        case .T2_huntingKnife: return "Iron Hunting Knife"
        case .T3_axe: return "Darksteel Axe"
        case .T3_pickaxe: return "Darksteel Pickaxe"
        case .T3_huntingKnife: return "Darksteel Hunting Knife"
        case .T4_axe: return "Cobaltite Axe"
        case .T4_pickaxe: return "Cobaltite Pickaxe"
        case .T4_huntingKnife: return "Cobaltite Hunting Knife"
        case .T5_axe: return "Mithril Axe"
        case .T5_pickaxe: return "Mithril Pickaxe"
        case .T5_huntingKnife: return "Mithril Hunting Knife"
        case .T6_axe: return "Obsidian Axe"
        case .T6_pickaxe: return "Obsidian Pickaxe"
        case .T6_huntingKnife: return "Obsidian Hunting Knife"
        case .T7_axe: return "Nacreum Axe"
        case .T7_pickaxe: return "Nacreum Pickaxe"
        case .T7_huntingKnife: return "Nacreum Hunting Knife"
        case .T8_axe: return "Ubronium Axe"
        case .T8_pickaxe: return "Ubronium Pickaxe"
        case .T8_huntingKnife: return "Ubronium Hunting Knife"
        case .T9_axe: return "Mantleborn Axe"
        case .T9_pickaxe: return "Mantleborn Pickaxe"
        case .T9_huntingKnife: return "Mantleborn Hunting Knife"
        case .T10_axe: return "Novaheart Axe"
        case .T10_pickaxe: return "Novaheart Pickaxe"
        case .T10_huntingKnife: return "Novaheart Hunting Knife"
        case .T11_axe: return "Dragonvein Master Axe"
        case .T11_pickaxe: return "Dragonvein Master Pickaxe"
        case .T11_huntingKnife: return "Dragonvein Master Hunting Knife"
        
    // Bags & Utility
        case .whetstone : return "Whetstone"
        case .T1_backpack: return "Hare Leather Backpack"
        case .T1_herbSatchel: return "Deer Leather Satchel"
        case .T2_backpack: return "Lynx Leather Backpack"
        case .T2_herbSatchel: return "Boar Leather Satchel"
        case .T3_backpack: return "Mist Elk Leather Backpack"
        case .T3_herbSatchel: return "Dire Wolf Leather Satchel"
        case .T4_backpack: return "Shadow Panther Leather Backpack"
        case .T4_herbSatchel: return "Kodiak Bear Leather Satchel"
        case .T5_backpack: return "Sabretooth Tiger Leather Backpack"
        case .T5_herbSatchel: return "Storm Basilisk Leather Satchel"
        case .T6_backpack: return "Fire Drake Leather Backpack"
        
    // Potions & Consumables
        case .T1_potion: return "T1 Potion"
        case .T2_potion: return "T2 Potion"
        case .T3_potion: return "T3 Potion"
        case .T4_potion: return "T4 Potion"
        case .T5_potion: return "T5 Potion"
        case .T6_potion: return "T6 Potion"
            
        case .basicPetTreat: return "Basic Pet Treat"
        case .gourmetPetTreat: return "Gourmet Pet Treat"
            
    // Hunting
        case .T1_bow: return "Willow Bow"
        case .T2_bow: return "Birch Bow"
        case .T3_bow: return "Walnut Bow"
        case .T4_bow: return "Black Cherry Bow"
        case .T5_bow: return "Lignum Vitae Bow"
        case .T6_bow: return "Red Oak Bow"
        case .T7_bow: return "Obsidianheart Bow"
        case .T8_bow: return "Silvershard Bow"
        case .T9_bow: return "Ebonywood Bow"
        case .T10_bow: return "Starbloom Bow"
        case .T11_bow: return "Aetherbloom Bow"
            
        case .T1_arrow: return "Copper Arrows"
        case .T2_arrow: return "Iron Arrows"
        case .T3_arrow: return "Darksteel Arrows"
        case .T4_arrow: return "Cobaltite Arrows"
        case .T5_arrow: return "Mithril Arrows"
        case .T6_arrow: return "Obsidian Arrows"
        case .T7_arrow: return "Nacreum Arrows"
        case .T8_arrow: return "Ubronium Arrows"
        case .T9_arrow: return "Mantleborn Arrows"
        case .T10_arrow: return "Novaheart Arrows"
        case .T11_arrow: return "Dragonvein Arrows"
    
    // Jewelcrafting
        case .T1_ring: return "Silver Sapphire Ring"
        case .T1_necklace: return "Silver Sapphire Amulet"
        case .T2_ring: return "Silver Emerald Ring"
        case .T2_necklace: return "Silver Emerald Amulet"
        case .T3_ring: return "Gold Ruby Ring"
        case .T3_necklace: return "Gold Ruby Amulet"
        case .T4_ring: return "Gold Diamond Ring"
        case .T4_necklace: return "Gold Diamond Amulet"
        case .T5_ring: return "Platinum Onyx Ring"
        case .T5_necklace: return "Platinum Onyx Amulet"
        case .T6_ring: return "Platinum Dragonstone Ring"
        case .T6_necklace: return "Platinum Dragonstone Amulet"
        }
    }
    
    var description: String {
        switch self {
    // TOOLS
//        case .makeshiftPickaxe: return "A crudely assembled pickaxe. Better than nothing."
//        case .makeshiftAxe: return "A basic axe, good for chopping softer woods."
//        case .crudeHuntingKnife: return "A sharp piece of stone attached to a handle, for skinning prey."
//        case .sturdyPickaxe: return "A well-made pickaxe capable of mining tougher ores."
//        case .sturdyAxe: return "A strong axe, able to fell resilient trees."
//        case .sturdyHuntingKnife: return "A sturdy knife for gathering hide from hunts."
        case .T0_huntingKnife: return "Makeshift Hunting Knife"
        case .T0_axe: return "Makeshift Woodcutting Axe"
        case .T0_pickaxe: return "Makeshift Pickaxe"
        case .T1_axe: return "Copper Axe"
        case .T1_pickaxe: return "Copper Pickaxe"
        case .T1_huntingKnife: return "Copper Hunting Knife"
        case .T2_axe: return "Iron Axe"
        case .T2_pickaxe: return "Iron Pickaxe"
        case .T2_huntingKnife: return "Iron Hunting Knife"
        case .T3_axe: return "Darksteel Axe"
        case .T3_pickaxe: return "Darksteel Pickaxe"
        case .T3_huntingKnife: return "Darksteel Hunting Knife"
        case .T4_axe: return "Cobaltite Axe"
        case .T4_pickaxe: return "Cobaltite Pickaxe"
        case .T4_huntingKnife: return "Cobaltite Hunting Knife"
        case .T5_axe: return "Mithril Axe"
        case .T5_pickaxe: return "Mithril Pickaxe"
        case .T5_huntingKnife: return "Mithril Hunting Knife"
        case .T6_axe: return "Obsidian Axe"
        case .T6_pickaxe: return "Obsidian Pickaxe"
        case .T6_huntingKnife: return "Obsidian Hunting Knife"
        case .T7_axe: return "Nacreum Axe"
        case .T7_pickaxe: return "Nacreum Pickaxe"
        case .T7_huntingKnife: return "Nacreum Hunting Knife"
        case .T8_axe: return "Ubronium Axe"
        case .T8_pickaxe: return "Ubronium Pickaxe"
        case .T8_huntingKnife: return "Ubronium Hunting Knife"
        case .T9_axe: return "Mantleborn Axe"
        case .T9_pickaxe: return "Mantleborn Pickaxe"
        case .T9_huntingKnife: return "Mantleborn Hunting Knife"
        case .T10_axe: return "Novaheart Axe"
        case .T10_pickaxe: return "Novaheart Pickaxe"
        case .T10_huntingKnife: return "Novaheart Hunting Knife"
        case .T11_axe: return "Dragonvein Master Axe"
        case .T11_pickaxe: return "Dragonvein Master Pickaxe"
        case .T11_huntingKnife: return "Dragonvein Master Hunting Knife"
            
    // GEAR / UTILITIES
        case .whetstone : return "Whetstone"
    // -- Herb Satchels --
        case .T1_herbSatchel:
            return "A simple satchel crafted from supple deer leather. Increases Herb carry capacity by 20."
        case .T2_herbSatchel:
            return "Tough boar leather reinforces this satchel, allowing for more careful storage. Increases Herb carry capacity by 40."
        case .T3_herbSatchel:
            return "Made from the surprisingly resilient pelt of a Dire Wolf, this satchel is both durable and spacious. Increases Herb carry capacity by 60."
        case .T4_herbSatchel:
            return "Crafted from thick Kodiak Bear hide, this satchel can withstand rough treatment while keeping delicate herbs safe. Increases Herb carry capacity by 80."
        case .T5_herbSatchel:
            return "The shimmering, magically-infused leather of a Storm Basilisk makes this satchel surprisingly light for its size. Increases Herb carry capacity by 100."
            
        // -- Backpacks --
        case .T1_backpack:
            return "A basic but functional backpack stitched together from several Field Hare pelts. Increases general resource carry capacity by 40."
        case .T2_backpack:
            return "Fashioned from the sleek hide of a Moonlight Lynx, this backpack is well-balanced and sturdy. Increases general resource carry capacity by 80."
        case .T3_backpack:
            return "The enchanted leather of a Mist Elk gives this backpack a faint, otherworldly resilience. Increases general resource carry capacity by 120."
        case .T4_backpack:
            return "Lined with the dark, tough hide of a Shadow Panther, this pack is designed for serious expeditions. Increases general resource carry capacity by 160."
        case .T5_backpack:
            return "The formidable hide of a Sabretooth Tiger, complete with reinforced stitching, creates an exceptionally large and durable pack. Increases general resource carry capacity by 200."
        case .T6_backpack:
            return "Crafted from the legendary, fire-resistant scales of a Fire Drake, this masterwork backpack can handle the heaviest of loads. Increases general resource carry capacity by 240."
    // POTIONS & CONSUMABLES
//        case .minorGatherersDraught: return "A weak concoction that temporarily sharpens the senses, increasing gathered yields."
//        case .minorSwiftnessTonic: return "A simple tonic that briefly quickens your step (effect conceptual)."
        case .T1_potion: return "T1 Potion"
        case .T2_potion: return "T2 Potion"
        case .T3_potion: return "T3 Potion"
        case .T4_potion: return "T4 Potion"
        case .T5_potion: return "T5 Potion"
        case .T6_potion: return "T6 Potion"
            
        case .basicPetTreat: return "A simple but nutritious treat. Hatchlings seem to love it."
        case .gourmetPetTreat: return "A carefully prepared, delicious treat. Greatly accelerates a hatchling's growth."
    
    // HUNTING
        case .T1_bow: return "Willow Bow"
        case .T2_bow: return "Birch Bow"
        case .T3_bow: return "Walnut Bow"
        case .T4_bow: return "Black Cherry Bow"
        case .T5_bow: return "Lignum Vitae Bow"
        case .T6_bow: return "Red Oak Bow"
        case .T7_bow: return "Obsidianheart Bow"
        case .T8_bow: return "Silvershard Bow"
        case .T9_bow: return "Ebonywood Bow"
        case .T10_bow: return "Starbloom Bow"
        case .T11_bow: return "Aetherbloom Bow"
            
        case .T1_arrow: return "Copper Arrows"
        case .T2_arrow: return "Iron Arrows"
        case .T3_arrow: return "Darksteel Arrows"
        case .T4_arrow: return "Cobaltite Arrows"
        case .T5_arrow: return "Mithril Arrows"
        case .T6_arrow: return "Obsidian Arrows"
        case .T7_arrow: return "Nacreum Arrows"
        case .T8_arrow: return "Ubronium Arrows"
        case .T9_arrow: return "Mantleborn Arrows"
        case .T10_arrow: return "Novaheart Arrows"
        case .T11_arrow: return "Dragonvein Arrows"
            
    // JEWELCRAFTING
        case .T1_ring: return "Silver Sapphire Ring"
        case .T1_necklace: return "Silver Sapphire Amulet"
        case .T2_ring: return "Silver Emerald Ring"
        case .T2_necklace: return "Silver Emerald Amulet"
        case .T3_ring: return "Gold Ruby Ring"
        case .T3_necklace: return "Gold Ruby Amulet"
        case .T4_ring: return "Gold Diamond Ring"
        case .T4_necklace: return "Gold Diamond Amulet"
        case .T5_ring: return "Platinum Onyx Ring"
        case .T5_necklace: return "Platinum Onyx Amulet"
        case .T6_ring: return "Platinum Dragonstone Ring"
        case .T6_necklace: return "Platinum Dragonstone Amulet"
            
        }
    }
    
    var iconAssetName: String { 
        switch self {
    // TOOLS
        case .T0_axe: return "T0_axe"
        case .T0_pickaxe: return "T0_pickaxe"
        case .T0_huntingKnife: return "T0_knife"
            
        case .T1_axe: return "T1_axe"
        case .T1_pickaxe: return "T1_pickaxe"
        case .T1_huntingKnife: return "T1_knife"
            
        case .T2_axe: return "T2_axe"
        case .T2_pickaxe: return "T2_pickaxe"
        case .T2_huntingKnife: return "T2_knife"
            
        case .T3_axe: return "T3_axe"
        case .T3_pickaxe: return "T3_pickaxe"
        case .T3_huntingKnife: return "T3_knife"
            
        case .T4_axe: return "T4_axe"
        case .T4_pickaxe: return "T4_pickaxe"
        case .T4_huntingKnife: return "T4_knife"
            
        case .T5_axe: return "T5_axe"
        case .T5_pickaxe: return "T5_pickaxe"
        case .T5_huntingKnife: return "T5_knife"
            
        case .T6_axe: return "T6_axe"
        case .T6_pickaxe: return "T6_pickaxe"
        case .T6_huntingKnife: return "T6_knife"
            
        case .T7_axe: return "T7_axe"
        case .T7_pickaxe: return "T7_pickaxe"
        case .T7_huntingKnife: return "T7_knife"
            
        case .T8_axe: return "T8_axe"
        case .T8_pickaxe: return "T8_pickaxe"
        case .T8_huntingKnife: return "T8_knife"
            
        case .T9_axe: return "T9_axe"
        case .T9_pickaxe: return "T9_pickaxe"
        case .T9_huntingKnife: return "T9_knife"
            
        case .T10_axe: return "T10_axe"
        case .T10_pickaxe: return "T10_pickaxe"
        case .T10_huntingKnife: return "T10_knife"
            
        case .T11_axe: return "T11_axe"
        case .T11_pickaxe: return "T11_pickaxe"
        case .T11_huntingKnife: return "T11_knife"
            
    // BAGS & UTILITY
        case .whetstone : return "whetstone"
            
        case .T1_backpack: return "T1_backpack"
        case .T1_herbSatchel: return "T1_satchel"
        case .T2_backpack: return "T2_backpack"
        case .T2_herbSatchel: return "T2_satchel"
        case .T3_backpack: return "T3_backpack"
        case .T3_herbSatchel: return "T3_satchel"
        case .T4_backpack: return "T4_backpack"
        case .T4_herbSatchel: return "T4_satchel"
        case .T5_backpack: return "T5_backpack"
        case .T5_herbSatchel: return "T5_satchel"
        case .T6_backpack: return "T6_backpack"
        
    // POTIONS & CONSUMABLES
        case .T1_potion: return "T1_potion"
        case .T2_potion: return "T2_potion"
        case .T3_potion: return "T3_potion"
        case .T4_potion: return "T4_potion"
        case .T5_potion: return "T5_potion"
        case .T6_potion: return "T6_potion"
            
        case .basicPetTreat: return "pet_treat_basic_icon" // You'll need to create this asset
        case .gourmetPetTreat: return "pet_treat_gourmet_icon" // You'll need to create this asset
    
    // Hunting
        case .T1_bow: return "T1_bow"
        case .T2_bow: return "T2_bow"
        case .T3_bow: return "T3_bow"
        case .T4_bow: return "T4_bow"
        case .T5_bow: return "T5_bow"
        case .T6_bow: return "T6_bow"
        case .T7_bow: return "T7_bow"
        case .T8_bow: return "T8_bow"
        case .T9_bow: return "T9_bow"
        case .T10_bow: return "T10_bow"
        case .T11_bow: return "T11_bow"
        case .T1_arrow: return "T1_arrow"
        case .T2_arrow: return "T2_arrow"
        case .T3_arrow: return "T3_arrow"
        case .T4_arrow: return "T4_arrow"
        case .T5_arrow: return "T5_arrow"
        case .T6_arrow: return "T6_arrow"
        case .T7_arrow: return "T7_arrow"
        case .T8_arrow: return "T8_arrow"
        case .T9_arrow: return "T9_arrow"
        case .T10_arrow: return "T10_arrow"
        case .T11_arrow: return "T11_arrow"
            
    // JEWELCRAFTING
        case .T1_ring: return "sapphireRing"
        case .T1_necklace: return "sapphireNecklace"
        case .T2_ring: return "emeraldRing"
        case .T2_necklace: return "emergaldNecklace"
        case .T3_ring: return "rubyRing"
        case .T3_necklace: return "rubyNecklace"
        case .T4_ring: return "diamondRing"
        case .T4_necklace: return "diamondNecklace"
        case .T5_ring: return "onyxRing"
        case .T5_necklace: return "onyxNecklace"
        case .T6_ring: return "dragonstoneRing"
        case .T6_necklace: return "dragonstoneNecklace"
        }
    }
    
    // --- Define which bag this one upgrades/replaces (optional, but useful data) ---
    var upgradesBagType: ItemType? {
        switch self {
        case .T2_backpack: return .T1_backpack
        case .T2_herbSatchel: return .T1_herbSatchel
        case .T3_backpack: return .T2_backpack
        case .T3_herbSatchel: return .T2_herbSatchel
        case .T4_backpack: return .T3_backpack
        case .T4_herbSatchel: return .T3_herbSatchel
        case .T5_backpack: return .T4_backpack
        case .T5_herbSatchel: return .T4_herbSatchel
        case .T6_backpack: return .T5_backpack
        default: return nil
        }
    }
    
    // NEW: What slot does this item go into?
    var equipmentSlot: EquipmentSlot? {
        switch self {
        case .T1_ring, .T2_ring, .T3_ring, .T4_ring, .T5_ring, .T6_ring: return .ring
        case .T1_necklace, .T2_necklace, .T3_necklace, .T4_necklace, .T5_necklace, .T6_necklace: return .necklace
        case .T1_herbSatchel, .T2_herbSatchel, .T3_herbSatchel, .T4_herbSatchel, .T5_herbSatchel: return .satchel
        case .T1_backpack, .T2_backpack, .T3_backpack, .T4_backpack, .T5_backpack, .T6_backpack: return .backpack
    // <<< Assign slots to tools >>>
        case .T0_pickaxe, .T1_pickaxe, .T2_pickaxe, .T3_pickaxe, .T4_pickaxe, .T5_pickaxe, .T6_pickaxe, .T7_pickaxe, .T8_pickaxe, .T9_pickaxe, .T10_pickaxe, .T11_pickaxe:
            return .pickaxe
        case .T0_axe, .T1_axe, .T2_axe, .T3_axe, .T4_axe, .T5_axe, .T6_axe, .T7_axe, .T8_axe, .T9_axe, .T10_axe, .T11_axe:
            return .axe
        case .T0_huntingKnife, .T1_huntingKnife, .T2_huntingKnife, .T3_huntingKnife, .T4_huntingKnife, .T5_huntingKnife, .T6_huntingKnife, .T7_huntingKnife, .T8_huntingKnife, .T9_huntingKnife, .T10_huntingKnife, .T11_huntingKnife:
            return .knife
        case .T1_bow, .T2_bow, .T3_bow, .T4_bow, .T5_bow, .T6_bow, .T7_bow, .T8_bow, .T9_bow, .T10_bow, .T11_bow:
            return .bow
        case .T1_arrow, .T2_arrow, .T3_arrow, .T4_arrow, .T5_arrow, .T6_arrow, .T7_arrow, .T8_arrow, .T9_arrow, .T10_arrow, .T11_arrow:
            return .arrows
        // ... add cases for future gear like head, body, legs, gloves ...
        default: return nil
        }
    }
    
    // NEW: What passive stat bonuses does this item provide?
    // The Double represents the bonus value (e.g., 0.05 for +5%)
    var statBonuses: [PlayerStat: Double]? {
        switch self {
        // Rings (example bonuses)
        case .T1_ring: return [.foragingXpBonus: 0.03] // +3% Foraging XP
        case .T2_ring: return [.woodcuttingXpBonus: 0.05] // +5% Woodcutting XP
        case .T3_ring: return [.miningXpBonus: 0.07] // +7% Mining XP
            
        // Necklaces
        case .T1_necklace: return [.rareFindChanceBonus: 0.01] // +1% to all rare drop chances
        case .T2_necklace: return [.globalXpBonus: 0.03] // +3% to ALL XP gain
        case .T3_necklace: return [.huntingSuccessChanceBonus: 0.05] // +5% to hunt success

        // Bags provide their bonus via specific capacity properties, not this stat system,
        // but could also provide a secondary stat here if you wanted.
        
        default: return nil
        }
    }
    
    // Define crafting recipes for items
    // An item recipe can require both Resources and Components
    struct ItemRecipe {
        let resources: [ResourceType: Int]?
        let components: [ComponentType: Int]?
        let items: [ItemType: Int]?
        let requiredUpgrade: BaseUpgradeType?
        let skillXP: [SkillType: Int]?
        init(resources: [ResourceType: Int]? = nil,
             components: [ComponentType: Int]? = nil,
             items: [ItemType: Int]? = nil,
             requiredUpgrade: BaseUpgradeType?,
             skillXP: [SkillType: Int]? = nil) {
            self.resources = resources
            self.components = components
            self.items = items
            self.requiredUpgrade = requiredUpgrade
            self.skillXP = skillXP
        }
    }
    
    var recipe: ItemRecipe? {
        switch self {
        case .T0_pickaxe:
            return ItemRecipe(components: [.T0_pickaxeH: 1, .T0_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 10])
        case .T1_pickaxe:
            return ItemRecipe(components: [.T1_pickaxeH: 1, .T1_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 15])
        case .T2_pickaxe:
            return ItemRecipe(components: [.T2_pickaxeH: 1, .T2_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 30])
        case .T3_pickaxe:
            return ItemRecipe(components: [.T3_pickaxeH: 1, .T3_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 45])
        case .T4_pickaxe:
            return ItemRecipe(components: [.T4_pickaxeH: 1, .T4_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 60])
        case .T5_pickaxe:
            return ItemRecipe(components: [.T5_pickaxeH: 1, .T5_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 75])
        case .T6_pickaxe:
            return ItemRecipe(components: [.T6_pickaxeH: 1, .T6_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 90])
        case .T7_pickaxe:
            return ItemRecipe(components: [.T7_pickaxeH: 1, .T7_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 105])
        case .T8_pickaxe:
            return ItemRecipe(components: [.T8_pickaxeH: 1, .T8_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 120])
        case .T9_pickaxe:
            return ItemRecipe(components: [.T9_pickaxeH: 1, .T9_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 135])
        case .T10_pickaxe:
            return ItemRecipe(components: [.T10_pickaxeH: 1, .T10_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 150])
        case .T11_pickaxe:
            return ItemRecipe(components: [.T11_pickaxeH: 1, .T11_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 175])
            
        case .T0_axe:
            return ItemRecipe(components: [.T0_axeHead: 1, .T0_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 10])
        case .T1_axe:
            return ItemRecipe(components: [.T1_axeHead: 1, .T1_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 15])
        case .T2_axe:
            return ItemRecipe(components: [.T2_axeHead: 1, .T2_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 30])
        case .T3_axe:
            return ItemRecipe(components: [.T3_axeHead: 1, .T3_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 45])
        case .T4_axe:
            return ItemRecipe(components: [.T4_axeHead: 1, .T4_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 60])
        case .T5_axe:
            return ItemRecipe(components: [.T5_axeHead: 1, .T5_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 75])
        case .T6_axe:
            return ItemRecipe(components: [.T6_axeHead: 1, .T6_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 90])
        case .T7_axe:
            return ItemRecipe(components: [.T7_axeHead: 1, .T7_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 105])
        case .T8_axe:
            return ItemRecipe(components: [.T8_axeHead: 1, .T8_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 120])
        case .T9_axe:
            return ItemRecipe(components: [.T9_axeHead: 1, .T9_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 135])
        case .T10_axe:
            return ItemRecipe(components: [.T10_axeHead: 1, .T10_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 150])
        case .T11_axe:
            return ItemRecipe(components: [.T11_axeHead: 1, .T11_axeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 175])
            
        case .T0_huntingKnife:
            return ItemRecipe(components: [.T0_knifeBlade: 1, .T0_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 10])
        case .T1_huntingKnife:
            return ItemRecipe(components: [.T1_knifeBlade: 1, .T1_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 10])
        case .T2_huntingKnife:
            return ItemRecipe(components: [.T2_knifeBlade: 1, .T2_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 20])
        case .T3_huntingKnife:
            return ItemRecipe(components: [.T3_knifeBlade: 1, .T3_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 30])
        case .T4_huntingKnife:
            return ItemRecipe(components: [.T4_knifeBlade: 1, .T4_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 40])
        case .T5_huntingKnife:
            return ItemRecipe(components: [.T5_knifeBlade: 1, .T5_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 50])
        case .T6_huntingKnife:
            return ItemRecipe(components: [.T6_knifeBlade: 1, .T6_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 60])
        case .T7_huntingKnife:
            return ItemRecipe(components: [.T7_knifeBlade: 1, .T7_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 70])
        case .T8_huntingKnife:
            return ItemRecipe(components: [.T8_knifeBlade: 1, .T8_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 80])
        case .T9_huntingKnife:
            return ItemRecipe(components: [.T9_knifeBlade: 1, .T9_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 90])
        case .T10_huntingKnife:
            return ItemRecipe(components: [.T10_knifeBlade: 1, .T10_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 100])
        case .T11_huntingKnife:
            return ItemRecipe(components: [.T11_knifeBlade: 1, .T11_knifeHandle: 1], requiredUpgrade: .woodworkingShop, skillXP: [.carpentry: 120])
            
    // --- BAG RECIPES ---
        case .T1_herbSatchel:
            return ItemRecipe(components: [.T2_leather: 2, .buckle: 1], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50])
            
        case .T2_herbSatchel:
            return ItemRecipe(
                components: [.buckle: 2, .T4_leather: 3],
//                items: [.T1_herbSatchel: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50]
            )
        case .T3_herbSatchel:
            return ItemRecipe(
                components: [.buckle: 2, .T6_leather: 3],
//                items: [.T2_herbSatchel: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50]
            )
        case .T4_herbSatchel:
            return ItemRecipe(
                components: [.buckle: 2, .T8_leather: 3],
//                items: [.T3_herbSatchel: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50]
            )
        case .T5_herbSatchel:
            return ItemRecipe(
                components: [.buckle: 2, .T10_leather: 3],
//                items: [.T4_herbSatchel: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 50]
            )
        case .T1_backpack:
            return ItemRecipe(components: [.buckle: 3, .T1_leather: 5], requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 75])
        case .T2_backpack:
            return ItemRecipe(
                components: [.buckle: 3, .T3_leather: 5],
//                items: [.T1_backpack: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 150])
        case .T3_backpack:
            return ItemRecipe(
                components: [.buckle: 3, .T5_leather: 5],
//                items: [.T2_backpack: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 225])
        case .T4_backpack:
            return ItemRecipe(
                components: [.buckle: 3, .T7_leather: 5],
//                items: [.T3_backpack: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 375])
        case .T5_backpack:
            return ItemRecipe(
                components: [.buckle: 3, .T9_leather: 5],
//                items: [.T4_backpack: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 550])
        case .T6_backpack:
            return ItemRecipe(
                components: [.buckle: 3, .T11_leather: 5],
//                items: [.T5_backpack: 1], // Consumes the lower-tier item
                requiredUpgrade: .tanningRack, skillXP: [.leatherworking: 750])
            
    // --- Potion & Consumables Recipes ---
        case .T1_potion:
            return ItemRecipe(components: [.T1_plantComp: 2, .T2_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 100])
        case .T2_potion:
            return ItemRecipe(components: [.T3_plantComp: 2, .T4_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 200])
        case .T3_potion:
            return ItemRecipe(components: [.T5_plantComp: 2, .T6_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 400])
        case .T4_potion:
            return ItemRecipe(components: [.T7_plantComp: 2, .T8_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 800])
        case .T5_potion:
            return ItemRecipe(components: [.T9_plantComp: 2, .T10_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 1600])
        case .T6_potion:
            return ItemRecipe(components: [.T9_plantComp: 2, .T10_plantComp: 2, .T11_plantComp: 2],
                  requiredUpgrade: .apothecaryStand, skillXP: [.herblore: 3200])
            
        case .basicPetTreat:
            return ItemRecipe(
                resources: [.T1_hide: 2, .T2_herb: 5],
                requiredUpgrade: .apothecaryStand,
                skillXP: [.herblore: 10]
            )
        case .gourmetPetTreat:
            return ItemRecipe(
                resources: [.T5_hide: 1, .T6_herb: 3],
                requiredUpgrade: .apothecaryStand,
                skillXP: [.herblore: 50]
            )
            
    // --- Fletching Recipes ---
            
        case .T1_bow:
            return ItemRecipe(components: [.T1_uBow: 1, .T1_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 100])
        case .T2_bow:
            return ItemRecipe(components: [.T2_uBow: 1, .T2_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 200])
        case .T3_bow:
            return ItemRecipe(components: [.T3_uBow: 1, .T3_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 350])
        case .T4_bow:
            return ItemRecipe(components: [.T4_uBow: 1, .T4_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 600])
        case .T5_bow:
            return ItemRecipe(components: [.T5_uBow: 1, .T5_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 950])
        case .T6_bow:
            return ItemRecipe(components: [.T6_uBow: 1, .T6_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 1400])
        case .T7_bow:
            return ItemRecipe(components: [.T7_uBow: 1, .T7_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 2000])
        case .T8_bow:
            return ItemRecipe(components: [.T8_uBow: 1, .T8_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 2750])
        case .T9_bow:
            return ItemRecipe(components: [.T9_uBow: 1, .T9_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 3750])
        case .T10_bow:
            return ItemRecipe(components: [.T10_uBow: 1, .T10_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 5000])
        case .T11_bow:
            return ItemRecipe(components: [.T11_uBow: 1, .T11_leather: 1], // Bow + String
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 7500])
        case .T1_arrow:
            // Recipe: 10 Arrow Shafts + 10 Bronze Arrowhead + 20 Feathers -> yields 10 arrows
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T1_plank: 1, .T1_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 30])
        case .T2_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T2_plank: 1, .T2_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 60])
        case .T3_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T3_plank: 1, .T3_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 105])
        case .T4_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T4_plank: 1, .T4_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 180])
        case .T5_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T5_plank: 1, .T5_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 325])
        case .T6_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T6_plank: 1, .T6_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 500])
        case .T7_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T7_plank: 1, .T7_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 700])
        case .T8_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T8_plank: 1, .T8_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 950])
        case .T9_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T9_plank: 1, .T9_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 1400])
        case .T10_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T10_plank: 1, .T10_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 2000])
        case .T11_arrow:
            return ItemRecipe(resources: [.feathers: 20], // Uses raw resource
                              components: [.T11_plank: 1, .T11_aHead: 10],
                              requiredUpgrade: .fletchingWorkshop,
                              skillXP: [.fletching: 2750])
            
    // JEWELCRAFTING
        case .T1_ring:
            return ItemRecipe(components: [.T1_cutGemstone: 1, .silverIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 100])
        case .T2_ring:
            return ItemRecipe(components: [.T2_cutGemstone: 1, .silverIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 500])
        case .T3_ring:
            return ItemRecipe(components: [.T3_cutGemstone: 1, .goldIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 1200])
        case .T4_ring:
            return ItemRecipe(components: [.T4_cutGemstone: 1, .goldIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 2100])
        case .T5_ring:
            return ItemRecipe(components: [.T5_cutGemstone: 1, .platinumIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 3500])
        case .T6_ring:
            return ItemRecipe(components: [.T6_cutGemstone: 1, .platinumIngot: 1],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 5500])
        case .T1_necklace:
            return ItemRecipe(components: [.T1_cutGemstone: 1, .silverIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 150])
        case .T2_necklace:
            return ItemRecipe(components: [.T2_cutGemstone: 1, .silverIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 750])
        case .T3_necklace:
            return ItemRecipe(components: [.T3_cutGemstone: 1, .goldIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 1800])
        case .T4_necklace:
            return ItemRecipe(components: [.T4_cutGemstone: 1, .goldIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 3050])
        case .T5_necklace:
            return ItemRecipe(components: [.T5_cutGemstone: 1, .platinumIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 5250])
        case .T6_necklace:
            return ItemRecipe(components: [.T6_cutGemstone: 1, .platinumIngot: 2],
                              requiredUpgrade: .jewelCraftingWorkshop,
                              skillXP: [.jewelcrafting: 8250])
        

        @unknown default:
            // This case handles any future ItemType cases you might add
            // and forget to define a recipe for.
            print("Warning: Recipe not defined for ItemType \(self.rawValue)")
            return nil
        }
    }
    
    // Amount crafted per recipe (for stackable items like arrows)
    var craftYield: Int {
        switch self {
        case .T1_arrow: return 10 // Crafting once yields 10 arrows
        case .T2_arrow: return 10
        case .T3_arrow: return 10
        case .T4_arrow: return 10
        case .T5_arrow: return 10
        case .T6_arrow: return 10
        case .T7_arrow: return 10
        case .T8_arrow: return 10
        case .T9_arrow: return 10
        case .T10_arrow: return 10
        case .T11_arrow: return 10
        default: return 1
        }
    }
    // MAX DURABILITY FOR ITEMS THAT HAVE IT
    var maxDurability: Int? {
        switch self {
        case .T0_axe, .T0_pickaxe, .T0_huntingKnife: return 15
        case .T1_axe, .T1_pickaxe, .T1_huntingKnife, .T1_bow: return 25
        case .T2_axe, .T2_pickaxe, .T2_huntingKnife, .T2_bow: return 30
        case .T3_axe, .T3_pickaxe, .T3_huntingKnife, .T3_bow: return 40
        case .T4_axe, .T4_pickaxe, .T4_huntingKnife, .T4_bow: return 50
        case .T5_axe, .T5_pickaxe, .T5_huntingKnife, .T5_bow: return 60
        case .T6_axe, .T6_pickaxe, .T6_huntingKnife, .T6_bow: return 70
        case .T7_axe, .T7_pickaxe, .T7_huntingKnife, .T7_bow: return 80
        case .T8_axe, .T8_pickaxe, .T8_huntingKnife, .T8_bow: return 90
        case .T9_axe, .T9_pickaxe, .T9_huntingKnife, .T9_bow: return 100
        case .T10_axe, .T10_pickaxe, .T10_huntingKnife, .T10_bow: return 120
        case .T11_axe, .T11_pickaxe, .T11_huntingKnife, .T11_bow: return 150
            // Add other tools here later
        default: return nil // Not all items have durability
        }
    }
    
    var repairAmount: Int? {
           switch self {
           case .whetstone: return 10 // Restores 10 durability
           default: return nil
           }
       }
    
    var growthTimeReduction: TimeInterval? {
            switch self {
            case .basicPetTreat: return 60 * 30  // 30 minutes
            case .gourmetPetTreat: return 60 * 60 * 2 // 2 hours
            default: return nil
            }
        }
    
    // How much bonus this bow gives to the hunt success chance
    var huntSuccessBonus: Double {
        switch self {
        // Tiers are examples, adjust to your actual ItemType cases
        case .T1_bow: return 0.05 // +5%
        case .T2_bow: return 0.10 // +10%
        case .T3_bow: return 0.15
        case .T4_bow: return 0.20
        case .T5_bow: return 0.25
        case .T6_bow: return 0.30
        case .T7_bow: return 0.35
        case .T8_bow: return 0.40
        case .T9_bow: return 0.45
        case .T10_bow: return 0.50
        case .T11_bow: return 0.55
        default: return 0.0
        }
    }

    // How much bonus these arrows give to the hunt success chance
    var arrowSuccessBonus: Double {
        switch self {
        case .T1_arrow: return 0.02 // +2%
        case .T2_arrow: return 0.05 // +5%
        case .T3_arrow: return 0.08
        case .T4_arrow: return 0.11
        case .T5_arrow: return 0.14
        case .T6_arrow: return 0.17
        case .T7_arrow: return 0.20
        case .T8_arrow: return 0.23
        case .T9_arrow: return 0.26
        case .T10_arrow: return 0.29
        case .T11_arrow: return 0.32
        default: return 0.0
        }
    }
    
    // Potion Effect Information
    var potionEffect: PotionEffect? {
        switch self {
//        case .minorGatherersDraught:
//            return PotionEffect(type: .increasedYield, magnitude: 1.2, duration: 60 * 5) // 20% increase for 5 minutes
//        case .minorSwiftnessTonic:
//            return PotionEffect(type: .increasedSpeed, magnitude: 1.25, duration: 60 * 2) // 25% speed for 2 minutes (conceptual)
        default:
            return nil
        }
    }
    
    // TIER FOR ITEMS (ESPECIALLY TOOLS)
    var tier: Int {
        switch self {
    // Special items
        case .whetstone, .basicPetTreat, .gourmetPetTreat:
            return -1
            
        case .T0_axe, .T0_pickaxe, .T0_huntingKnife:
            return 0
        case .T1_axe, .T1_pickaxe, .T1_huntingKnife, .T1_bow, .T1_arrow, .T1_backpack, .T1_herbSatchel, .T1_potion, .T1_ring:
            return 1
        case .T2_axe, .T2_pickaxe, .T2_bow, .T2_huntingKnife, .T2_arrow, .T2_backpack, .T2_herbSatchel, .T2_potion, .T1_necklace:
            return 2
        case .T3_axe, .T3_pickaxe, .T3_huntingKnife, .T3_bow, .T3_arrow, .T3_potion, .T3_backpack, .T3_herbSatchel, .T2_ring:
            return 3
        case .T4_axe, .T4_pickaxe, .T4_huntingKnife, .T4_bow, .T4_arrow, .T4_potion, .T4_backpack, .T4_herbSatchel, .T2_necklace:
            return 4
        case .T5_axe, .T5_pickaxe, .T5_huntingKnife, .T5_bow, .T5_arrow, .T5_potion, .T5_backpack, .T5_herbSatchel, .T3_ring:
            return 5
        case .T6_axe, .T6_pickaxe, .T6_huntingKnife, .T6_bow, .T6_arrow, .T6_potion, .T6_backpack, .T3_necklace:
            return 6
        case .T7_axe, .T7_pickaxe, .T7_huntingKnife, .T7_bow, .T7_arrow, .T4_ring:
            return 7
        case .T8_axe, .T8_pickaxe, .T8_huntingKnife, .T8_bow, .T8_arrow, .T4_necklace:
            return 8
        case .T9_axe, .T9_pickaxe, .T9_huntingKnife, .T9_bow, .T9_arrow, .T5_ring:
            return 9
        case .T10_axe, .T10_pickaxe, .T10_huntingKnife, .T10_bow, .T10_arrow, .T5_necklace:
            return 10
        case .T11_axe, .T11_pickaxe, .T11_huntingKnife, .T11_bow, .T11_arrow, .T6_ring, .T6_necklace:
            return 11
        }
    }
    
    var toolCategory: ToolCategory {
            switch self {
            case _ where self.equipmentSlot == .pickaxe: return .pickaxe
            case _ where self.equipmentSlot == .axe: return .axe
            case _ where self.equipmentSlot == .knife: return .knife
            case _ where self.equipmentSlot == .bow: return .bow
            case _ where self.equipmentSlot == .arrows: return .arrows
            default: return .none
            }
        }
    
    // Define capacity bonus provided by bags
    var herbCapacityBonus: Int {
        switch self {
        case .T1_herbSatchel: return 20
        case .T2_herbSatchel: return 40
        case .T3_herbSatchel: return 60
        case .T4_herbSatchel: return 80
        case .T5_herbSatchel: return 100
        default: return 0
        }
    }
    var generalResourceCapacityBonus: Int {
        switch self {
        case .T1_backpack: return 40
        case .T2_backpack: return 80
        case .T3_backpack: return 120
        case .T4_backpack: return 160
        case .T5_backpack: return 200
        case .T6_backpack: return 240
        default: return 0
        }
    }
}
    // Structs and Enums for Potion Effects
    enum PotionEffectType: String, Codable, Hashable { // Hashable for dictionary keys
        case increasedYield
        case increasedSpeed
        case increasedRareFind // For future
        // Add more effect types as needed
    }
    // Helper extension for PotionEffectType display name (add to PotionEffectType definition or here)
    extension PotionEffectType {
        func displayNameFromType() -> String {
            switch self {
            case .increasedYield: return "Increased Yield"
            case .increasedSpeed: return "Increased Speed"
            case .increasedRareFind: return "Increased Rare Find"
            }
        }
    }

    struct PotionEffect: Codable {
        let type: PotionEffectType
        let magnitude: Double // e.g., 1.2 for a 20% increase, or a flat +1, depends on how you use it
        let duration: TimeInterval // in seconds
    }
