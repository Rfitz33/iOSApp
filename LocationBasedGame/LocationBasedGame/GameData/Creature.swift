//
//  CreatureType.swift
//  LocationBasedGame
//
//  Created by Reid on 7/20/25.
//


// Creature.swift
import Foundation

/// A struct to define the static properties of a quest.
struct QuestDefinition {
    let id: String
    let title: String
    let description: String
    // The objectives and their required counts. e.g., ["ores_mined": 500]
    let objectives: [String: Int]
}

enum PetState: String, Codable {
    case hatchling      // Just hatched, growing over time.
    case untrainedAdult // Growth complete, ready for training quest.
    case trainedAdult   // Training complete, all abilities unlocked.
}

// Enum to define the types of creatures a player can own.
enum CreatureType: String, Codable, CaseIterable, Identifiable {
    case raven
    case owl
    case hawk
    case dragon

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .raven: return "Raven"
        case .owl: return "Owl"
        case .hawk: return "Hawk"
        case .dragon: return "Dragon"
        }
    }
    
    /// A player-facing description of the creature's unique trained ability.
    var specialAbilityDescription: String {
        switch self {
        case .raven:
            return "Scavenger: Has a chance to find extra basic resources for you on any successful gather."
        case .owl:
            return "Night Owl: Doubles its vision bonus during the night (8 PM - 6 AM)."
        case .hawk:
            return "Predator's Gaze: Increases hunt success chance and may conserve arrows on a successful hunt."
        case .dragon:
            return "Draconic Presence: A powerful aura that increases rare find chances, boosts XP gain, and can enrich nearby resources."
        }
    }
    
    var visionBonus: Double {
        switch self {
        case .raven: return 50.0
        case .owl: return 75.0
        case .hawk: return 100.0
        case .dragon: return 150.0
        }
    }
    
    // --- NEW FETCH PROPERTIES ---
    var maxFetchCharges: Int {
        switch self {
        case .raven: return 2
        case .owl: return 3
        case .hawk: return 4
        case .dragon: return 5
        }
    }

    var fetchCooldown: TimeInterval { // in seconds
        switch self {
        case .raven: return 60 * 15 // 15 minutes
        case .owl: return 60 * 15
        case .hawk: return 60 * 15
        case .dragon: return 60 * 10 // Dragon recharges faster
        }
    }
    
    var eggResourceType: ResourceType {
        switch self {
        case .raven: return .ravenEgg
        case .owl: return .owlEgg
        case .hawk: return .hawkEgg
        case .dragon: return .dragonEgg
        }
    }
    
    var incubationTime: TimeInterval {
        switch self {
        case .raven: return 60 // * 30
        case .owl: return 60 // * 60
        case .hawk: return 60 // * 60 * 2
        case .dragon: return 60 // * 60 * 8
        }
    }
    
    // --- NEW GAME DESIGN PROPERTIES ---
    
    /// The total duration in seconds for the pet to grow from a hatchling.
    var growthDuration: TimeInterval {
        switch self {
        case .raven: return 60 // * 60 * 48    // 48 hours
        case .owl: return 60 // * 60 * 72      // 72 hours
        case .hawk: return 60 // * 60 * 96     // 96 hours
        case .dragon: return 60 // * 60 * 168  // 1 week
        }
    }
    
    /// Defines the training quest for this creature type.
    var trainingQuest: QuestDefinition {
        switch self {
        case .raven:
            return QuestDefinition(
                id: "train_raven",
                title: "A Raven's Cunning",
                description: "Your raven is drawn to valuable things. Discover 5 rare items (Gems, Whetstones, or Feathers) with it as your companion.",
                objectives: ["rare_finds": 5]
            )
        case .owl:
            return QuestDefinition(
                id: "train_owl",
                title: "The Owl's Vigil",
                description: "The owlet must learn to see in the dark. Gather 100 resources at night (8 PM - 6 AM) with it as your companion.",
                objectives: ["night_gathers": 100]
            )
        case .hawk:
            return QuestDefinition(
                id: "train_hawk",
                title: "The Hawk's Eye",
                description: "The young hawk must learn to track swift prey. Successfully hunt 15 animals of Tier 5 or higher with it as your companion.",
                objectives: ["high_tier_hunts": 15]
            )
        case .dragon:
            return QuestDefinition(
                id: "train_dragon",
                title: "A Dragon's Might",
                description: "The whelp must temper its immense power through feats of mastery.",
                objectives: [
                    "t8_plus_ores": 500,
                    "t6_plus_ingots": 250,
                    "t10_plus_crafts": 4 // We'll just track the count. The UI will show the specific items.
                ]
            )
        }
    }
}

// Represents a hatched creature owned by the player.
struct Creature: Codable, Identifiable, Hashable {
    let id: UUID
    let type: CreatureType
    var name: String?
    
    // --- NEW LIFECYCLE PROPERTIES ---
    var state: PetState
    var growthStartTime: Date? // The moment it hatched, to track growth
    
    // We will use a simple dictionary to track quest progress.
    // e.g., ["ores_mined": 150, "hunts_complete": 5]
    var questProgress: [String: Int]
    
    // --- NEW FETCH PROPERTIES ---
    var fetchCharges: Int
    var chargeRestoreTimes: [Date] // Timestamps for when charges will be restored

    // --- MODIFIED INITIALIZER ---
    init(type: CreatureType, name: String? = nil) {
        self.id = UUID()
        self.type = type
        self.name = name ?? type.displayName
        
        // A new creature always starts as a hatchling.
        self.state = .hatchling
        self.growthStartTime = Date() // Start the growth timer immediately.
        self.questProgress = [:]    // Initialize with an empty progress dictionary.
        // A new creature starts with full charges.
        self.fetchCharges = type.maxFetchCharges
        self.chargeRestoreTimes = []
    }
}

// Represents an egg currently in an incubator slot.
// NOTE: This now correctly uses ResourceType.
struct IncubationSlot: Codable, Identifiable {
    let id: UUID
    let eggType: ResourceType
    let incubationStartTime: Date
    
    // Helper to get the CreatureType from the egg's ResourceType
    var creatureType: CreatureType? {
        return CreatureType.allCases.first { $0.eggResourceType == eggType }
    }
    
    init(eggType: ResourceType) {
        self.id = UUID()
        self.eggType = eggType
        self.incubationStartTime = Date()
    }
}
