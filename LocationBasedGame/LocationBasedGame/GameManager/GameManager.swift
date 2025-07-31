import Foundation
import Combine
import CoreLocation

// Helper struct for defining spawn characteristics of resources
struct ResourceSpawnInfo {
    let type: ResourceType
    let weight: Int // Higher weight = more common relative to others in the current spawnable pool
    let minSkillLevelToSee: Int // Minimum level of associated skill for this node to be considered for spawning
    let maxSkillLevelToConsiderSpawning: Int?
        // If nil, the resource potentially spawns indefinitely (or until its weight becomes very low due to other high-tier items)

    // Initializer to include the new property
    init(type: ResourceType, weight: Int, minSkillLevelToSee: Int, maxSkillLevelToConsiderSpawning: Int? = nil) {
        self.type = type
        self.weight = weight
        self.minSkillLevelToSee = minSkillLevelToSee
        self.maxSkillLevelToConsiderSpawning = maxSkillLevelToConsiderSpawning
    }
}

class GameManager: ObservableObject {
    static let shared = GameManager() // Singleton for easy access
    
    // Inventories (playerInventory didSet will call updateTotalResourceLoads)
    @Published var playerInventory: [ResourceType: Int] = [:] { didSet { saveInventory(); updateTotalResourceLoads() } }
    @Published var sanctumComponentStorage: [ComponentType: Int] = [:] { didSet { saveComponents() } }
    @Published var sanctumItemStorage: [ItemType: Int] = [:] { didSet { saveItemInventory(); updateTotalResourceLoads() } }
//    @Published var sanctumComponentStorage: [ComponentType: Int] = [:] { didSet { saveComponents() } }
//    @Published var sanctumItemStorage: [ItemType: Int] = [:] { didSet { saveItemInventory(); updateTotalResourceLoads() } } // Bags affect load
    @Published var currentToolDurability: [ItemType: Int] = [:] { didSet { saveToolDurability() } }
    @Published var activeBaseUpgrades: Set<BaseUpgradeType> = [] { didSet { saveBaseUpgradesState(); updateTotalResourceLoads() } }
    
    @Published var playerSkillsXP: [SkillType: Int] = [:] { didSet { saveSkillsState() } }
    @Published var playerSkillLevels: [SkillType: Int] = [:] { didSet { /* May not need a separate save if levels are derived */ } }
    @Published var activePotionEffects: [PotionEffectType: Date] = [:] { // EffectType -> ExpiryTime
        didSet { saveActivePotionEffects() }
    }
    @Published var assignedScoutTask: ResourceType? = nil { // Which resource the scout is focused on
        didSet { saveScoutState() }
    }
    
    // Feedback Properties
    @Published var lastScoutMessage: String? = nil // For scout gather feedback
    @Published var lastPotionStatusMessage: String? = nil
    @Published var messageLog: [LogMessage] = []
    @Published var feedbackPublisher = PassthroughSubject<FeedbackEvent, Never>()
    
    // Map-related State
    @Published var homeBase: HomeBase?
    @Published var isPlayerNearHomeBase: Bool = false // To control "Enter Base" button
    @Published var activeResourceNodes: [ResourceNode] = []
    
    // Durability
    let durabilitySaveChancePerLevel: Double = 0.05 // 5% chance per level above threshold
    let durabilitySaveLevelThreshold: Int = 3 // Player must be this many levels above resource req
    
    // Capacity State
    let baseHerbCapacity: Int = 30
    @Published var maxHerbCapacity: Int = 30
    @Published var currentHerbLoad: Int = 0
    
    let baseGeneralResourceCapacity: Int = 200
    @Published var maxGeneralResourceCapacity: Int = 200
    @Published var currentGeneralResourceLoad: Int = 0
    
    // Equipment & Bonuses
    var activeStatBonuses: [PlayerStat: Double] = [:]
    
    // --- NEW: Aviary & Pet Properties ---
    @Published var ownedCreatures: [Creature] = [] { didSet { saveCreaturesState() } }
    @Published var incubatingSlots: [IncubationSlot] = [] { didSet { saveIncubationState() } }
    @Published var activeCreatureID: UUID? = nil { didSet { saveCreaturesState();
        recalculateAllBonuses() } }
    @Published var unlockedPetTypes: Set<CreatureType> = [] { didSet { saveUnlockedPetTypes() } }
    // --- NEW: A dictionary to store time reductions for pet growth ---
    // We will save this along with the creature data.
    @Published var petGrowthReductions: [UUID: TimeInterval] = [:] { didSet { saveCreaturesState() } }
    @Published var lastFeatherCollectionTime: Date? { didSet { savePassiveFeatherState() } }
    @Published var accumulatedFeathers: Int = 0 { didSet { savePassiveFeatherState() } }
    // --- NEW: Watchtower Properties ---
    @Published var lastHorizonScanTime: Date? { didSet { saveWatchtowerState() } }
    // This will store the ID of the special node so we can track it.
    @Published var activeDiscoveryNodeID: UUID? { didSet { saveWatchtowerState() } }
    
    // MARK: State & Constants
    // Timers
    var worldUpdateTimer: Timer? // Renamed from resourceRechargeTimer
    var scoutsGatherTimer: Timer?
    
    // Location & Spawning State
    var currentLatestPlayerLocation: CLLocation?
    var lastPlayerLocationForSpawnTrigger: CLLocation?
    var lastPeriodicSpawnTime: Date?
    
    // Constants
    let worldUpdateInterval: TimeInterval = 15.0 // Check every 15 seconds (tune this)
    let periodicSpawnTimeThreshold: TimeInterval = 60 * 3 // Try to spawn new nodes every 3 minutes if stationary
    let periodicSpawnMovementThreshold: CLLocationDistance = 100 // Or if moved 100 meters
    let scoutsGatherInterval: TimeInterval = 60 * 10 // Example: Scouts gather every 10 minutes
    let scoutGatherAmount: Int = 1 // Example: Gather 1 unit of a resource
    let scoutStateStorageKey = "gameManager_scoutState_v1" // Use a versioned key
    let aviaryIncubationSlots: Int = 1 // Start with 1 slot
    let resourceSpawnRadius: Double = 150 // meters (e.g., spawn within 150m of player)
    let maxResourceNodes: Int = 10 // Max number of nodes on map at once (for simplicity)
    let gatherDistanceThreshold: Double = 125 // meters (must be within 100m to gather)
    let minDistanceBetweenNodes: Double = 30.0 // meters - Minimum distance between any two resource nodes
    let minDistanceFromBase: Double = 50.0   // meters - Minimum distance from home base for a resource node
    let levelUpPublisher = PassthroughSubject<LevelUpEvent, Never>()
    let questProgressPublisher = PassthroughSubject<QuestProgressEvent, Never>()
    let skillLevelCap = 50 // Already here, good.
    let baseXpPerLevel: Int = 100
    let watchtowerInfluenceRadius: Double = 500.0 // 500 meters
    let watchtowerScanCooldown: TimeInterval = 60 * 5 // * 60 * 23 // 23 hours
    
    // Storage Keys
    let homeBaseStorageKey = "gameManager_homeBase"
    let inventoryStorageKey = "gameManager_playerInventory"
    let toolDurabilityStorageKey = "gameManager_toolDurability"
    let componentsStorageKey = "gameManager_sanctumComponentStorage_v1"
    let itemInventoryStorageKey = "gameManager_sanctumItemStorage_v1"
    let creaturesStorageKey = "gameManager_creatures_v1"
    let incubationStorageKey = "gameManager_incubation_v1"
    let unlockedPetTypesKey = "gameManager_unlockedPetTypes_v1"
    let passiveFeatherStateKey = "gameManager_passiveFeatherState_v1"
    let watchtowerStateKey = "gameManager_watchtowerState_v1"
    
    // Store the currently equipped item for each slot
    @Published var equippedGear: [EquipmentSlot: ItemType] = [:] {
        didSet {
            saveEquippedGear()
            recalculateAllBonuses() // Recalculate stats when gear changes
        }
    }
    let equippedGearStorageKey = "gameManager_equippedGear_v1"
    
    // --- Home Base Upgrades ---
    // Store active upgrades in a Set for easier checking and persistence
    let baseUpgradesStorageKey = "gameManager_activeBaseUpgrades"
    let activePotionEffectsStorageKey = "gameManager_activePotionEffects"
    let skillsStorageKey = "gameManager_playerSkillsXP" // Store XP, derive level
    // XP required for next level (example: simple linear progression for now)
    // Level 1 = 0 XP, Level 2 needs 100 total XP, Level 3 needs 200 more (300 total), etc.
    // More complex: func xpForLevel(_ level: Int) -> Int { return level * level * 100 }
    
    
    @Published var isSettingHomeBaseMode: Bool = false // To toggle the UI for setting base
    let homeBaseEnterProximity: Double = 10000000.0 // meters (e.g., must be within 50m to "enter")
    
    let allUpgrades: [UpgradeDefinition] = [
        UpgradeDefinition(
            type: .basicForge,
            resources: [.T1_stone: 20, .T1_wood: 15],
            skillRequirements: [.mining: 3]),
        UpgradeDefinition(
            type: .woodworkingShop,
            resources: [.T1_stone: 15, .T1_wood: 25],
            skillRequirements: [.woodcutting: 3]),
        UpgradeDefinition(
            type: .tanningRack,
            resources: [.T1_stone: 10, .T1_wood: 10, .T1_hide: 15],
            skillRequirements: [.hunting: 3]),
        UpgradeDefinition(
            type: .apothecaryStand,
            resources: [.T1_stone: 10, .T1_wood: 10, .T1_hide: 5, .T2_herb: 10],
            skillRequirements: [.foraging: 3]),
        UpgradeDefinition(
            type: .basicStorehouse,
            components: [.T2_ingot: 15, .T2_plank: 15, .T2_leather: 10],
            prerequisites: [.basicForge, .woodworkingShop, .tanningRack],
            skillRequirements: [.mining: 5, .woodcutting: 5, .hunting: 5]),
        UpgradeDefinition(
            type: .fletchingWorkshop,
            components: [.T4_plank: 15, .T3_ingot: 10],
            prerequisites: [.woodworkingShop, .basicForge],
            skillRequirements: [.carpentry: 15, .smithing: 10]),
        UpgradeDefinition(
            type: .scoutsQuarters,
            components: [.T3_plank: 10, .T3_ingot: 10, .T3_leather: 10],
            skillRequirements: [.carpentry: 10, .smithing: 10, .leatherworking: 10]),
        UpgradeDefinition(
            type: .alchemyLab,
            components: [.T3_ingot: 15, .T3_plank: 15],
            prerequisites: [.apothecaryStand, .basicForge],
            skillRequirements: [.smithing: 10, .carpentry: 10]),
        UpgradeDefinition(
            type: .watchtower,
            components: [.T3_ingot: 15, .T3_plank: 15],
            prerequisites: [.apothecaryStand, .basicForge],
            skillRequirements: [.smithing: 10, .carpentry: 10]),
        UpgradeDefinition(
            type: .garden,
            resources: [.T2_herb: 10, .T3_herb: 10, .T4_herb: 5],
            components: [.T4_plank: 15, .T3_leather: 5],
            skillRequirements: [.foraging: 15, .carpentry: 15, .leatherworking: 10]),
        UpgradeDefinition(
            type: .aviary,
            components: [.T4_plank: 15, .T4_leather: 10],
            prerequisites: [.scoutsQuarters],
            skillRequirements: [.carpentry: 15, .leatherworking: 15]),
        UpgradeDefinition(
            type: .jewelCraftingWorkshop,
            components: [.T4_ingot: 10, .T3_plank: 15],
            prerequisites: [.basicForge],
            skillRequirements: [.smithing: 15, .carpentry: 10]),
        
    ]
    
    let masterResourceSpawnList: [ResourceSpawnInfo] = [
       // Mining Resources
        ResourceSpawnInfo(type: .silverOre,  weight: 10, minSkillLevelToSee: 15, maxSkillLevelToConsiderSpawning: 32),
        ResourceSpawnInfo(type: .goldOre,  weight: 8, minSkillLevelToSee: 27, maxSkillLevelToConsiderSpawning: 44),
        ResourceSpawnInfo(type: .platinumOre,  weight: 5, minSkillLevelToSee: 39),
        
       ResourceSpawnInfo(type: .stone,        weight: 100, minSkillLevelToSee: 1, maxSkillLevelToConsiderSpawning: 6),
       ResourceSpawnInfo(type: .T1_stone,    weight: 75,  minSkillLevelToSee: 2, maxSkillLevelToConsiderSpawning: 15),
       ResourceSpawnInfo(type: .T2_stone,    weight: 60,  minSkillLevelToSee: 5, maxSkillLevelToConsiderSpawning: 20),
       ResourceSpawnInfo(type: .T3_stone,    weight: 50,  minSkillLevelToSee: 10, maxSkillLevelToConsiderSpawning: 25),
       ResourceSpawnInfo(type: .T4_stone,    weight: 45,  minSkillLevelToSee: 15, maxSkillLevelToConsiderSpawning: 30),
       ResourceSpawnInfo(type: .T5_stone,    weight: 40,  minSkillLevelToSee: 20, maxSkillLevelToConsiderSpawning: 35),
       ResourceSpawnInfo(type: .T6_stone,    weight: 35,  minSkillLevelToSee: 25, maxSkillLevelToConsiderSpawning: 40),
       ResourceSpawnInfo(type: .T7_stone,    weight: 30,  minSkillLevelToSee: 30, maxSkillLevelToConsiderSpawning: 45),
       ResourceSpawnInfo(type: .T8_stone,    weight: 25,  minSkillLevelToSee: 35),
       ResourceSpawnInfo(type: .T9_stone,    weight: 20,  minSkillLevelToSee: 40),
       ResourceSpawnInfo(type: .T10_stone,   weight: 15,  minSkillLevelToSee: 45),
       ResourceSpawnInfo(type: .T11_stone,   weight: 10,  minSkillLevelToSee: 50),

       // Woodcutting Resources
        ResourceSpawnInfo(type: .T0_wood,    weight: 100,  minSkillLevelToSee: 1, maxSkillLevelToConsiderSpawning: 6),
       ResourceSpawnInfo(type: .T1_wood,    weight: 75,  minSkillLevelToSee: 2, maxSkillLevelToConsiderSpawning: 15),
       ResourceSpawnInfo(type: .T2_wood,    weight: 60,  minSkillLevelToSee: 5, maxSkillLevelToConsiderSpawning: 20),
       ResourceSpawnInfo(type: .T3_wood,    weight: 50,  minSkillLevelToSee: 10, maxSkillLevelToConsiderSpawning: 25),
       ResourceSpawnInfo(type: .T4_wood,    weight: 45,  minSkillLevelToSee: 15, maxSkillLevelToConsiderSpawning: 30),
       ResourceSpawnInfo(type: .T5_wood,    weight: 40,  minSkillLevelToSee: 20, maxSkillLevelToConsiderSpawning: 35),
       ResourceSpawnInfo(type: .T6_wood,    weight: 35,  minSkillLevelToSee: 25, maxSkillLevelToConsiderSpawning: 40),
       ResourceSpawnInfo(type: .T7_wood,    weight: 30,  minSkillLevelToSee: 30, maxSkillLevelToConsiderSpawning: 45),
       ResourceSpawnInfo(type: .T8_wood,    weight: 25,  minSkillLevelToSee: 35),
       ResourceSpawnInfo(type: .T9_wood,    weight: 20,  minSkillLevelToSee: 40),
       ResourceSpawnInfo(type: .T10_wood,   weight: 15,  minSkillLevelToSee: 45),
       ResourceSpawnInfo(type: .T11_wood,   weight: 10,  minSkillLevelToSee: 50),
       
       // Foraging Resources
       ResourceSpawnInfo(type: .T1_herb,    weight: 100,  minSkillLevelToSee: 1, maxSkillLevelToConsiderSpawning: 15),
       ResourceSpawnInfo(type: .T2_herb,    weight: 85,  minSkillLevelToSee: 5, maxSkillLevelToConsiderSpawning: 20),
       ResourceSpawnInfo(type: .T3_herb,    weight: 70,  minSkillLevelToSee: 10, maxSkillLevelToConsiderSpawning: 25),
       ResourceSpawnInfo(type: .T4_herb,    weight: 55,  minSkillLevelToSee: 15, maxSkillLevelToConsiderSpawning: 30),
       ResourceSpawnInfo(type: .T5_herb,    weight: 40,  minSkillLevelToSee: 20, maxSkillLevelToConsiderSpawning: 35),
       ResourceSpawnInfo(type: .T6_herb,    weight: 35,  minSkillLevelToSee: 25, maxSkillLevelToConsiderSpawning: 40),
       ResourceSpawnInfo(type: .T7_herb,    weight: 30,  minSkillLevelToSee: 30, maxSkillLevelToConsiderSpawning: 45),
       ResourceSpawnInfo(type: .T8_herb,    weight: 25,  minSkillLevelToSee: 35),
       ResourceSpawnInfo(type: .T9_herb,    weight: 20,  minSkillLevelToSee: 40),
       ResourceSpawnInfo(type: .T10_herb,   weight: 15,  minSkillLevelToSee: 45),
       ResourceSpawnInfo(type: .T11_herb,   weight: 10,  minSkillLevelToSee: 50),

       // Hunting Tracks
       ResourceSpawnInfo(type: .T1_tracks,    weight: 100,  minSkillLevelToSee: 1, maxSkillLevelToConsiderSpawning: 15),
       ResourceSpawnInfo(type: .T2_tracks,    weight: 85,  minSkillLevelToSee: 5, maxSkillLevelToConsiderSpawning: 20),
       ResourceSpawnInfo(type: .T3_tracks,    weight: 70,  minSkillLevelToSee: 10, maxSkillLevelToConsiderSpawning: 25),
       ResourceSpawnInfo(type: .T4_tracks,    weight: 55,  minSkillLevelToSee: 15, maxSkillLevelToConsiderSpawning: 30),
       ResourceSpawnInfo(type: .T5_tracks,    weight: 40,  minSkillLevelToSee: 20, maxSkillLevelToConsiderSpawning: 35),
       ResourceSpawnInfo(type: .T6_tracks,    weight: 35,  minSkillLevelToSee: 25, maxSkillLevelToConsiderSpawning: 40),
       ResourceSpawnInfo(type: .T7_tracks,    weight: 30,  minSkillLevelToSee: 30, maxSkillLevelToConsiderSpawning: 45),
       ResourceSpawnInfo(type: .T8_tracks,    weight: 25,  minSkillLevelToSee: 35),
       ResourceSpawnInfo(type: .T9_tracks,    weight: 20,  minSkillLevelToSee: 40),
       ResourceSpawnInfo(type: .T10_tracks,   weight: 15,  minSkillLevelToSee: 45),
       ResourceSpawnInfo(type: .T11_tracks,   weight: 10,  minSkillLevelToSee: 50),
       
   ]
    // Add all other ResourceTypes that should spawn on the map here.
    // Rawhide, ThickRawhide are products, so they don't spawn.
    // Tier 2 Gatherables (examples - adjust minSkillLevelToSee based on your PDF/design)
    // These "minSkillLevelToSee" values are for when the node *starts appearing on the map*.
    // The actual gathering might require a higher skill level (defined in ResourceType.requiredSkillLevel).
    
    // MARK: Lifecycle
    internal init() {
        print("GameManager initializing...")
        loadHomeBase()
        loadBaseUpgradesState()
        
        loadInventory()
        loadComponents()
        loadItemInventory()
        loadToolDurability()
        loadEquippedGear()
        recalculateAllBonuses() // Calculate initial stats from loaded gear
        loadSkillsState()
        loadActivePotionEffects()
        loadScoutState()
        loadWatchtowerState()
        loadCreaturesState()
        loadIncubationState()
        loadUnlockedPetTypes()
        loadPassiveFeatherState()
        
        updateAllSkillLevelsFromXP()
        updateTotalResourceLoads()
        
        startWorldUpdateTimer()
        // Start scouts timer if quarters are already built (e.g., from loaded state)
        if activeBaseUpgrades.contains(.scoutsQuarters) {
            startScoutsGatherTimer()
        }
        print("GameManager initialization complete.")
    }
    
    // Call this method when the app is about to terminate or go into a long background state
    // (e.g., in SceneDelegate's sceneDidEnterBackground or applicationWillTerminate)
    // For now, we are not handling backgrounding perfectly.
    deinit {
        stopWorldUpdateTimer()
        stopScoutsGatherTimer()
    }
    
    // Public method for ContentView to update location
    public func playerLocationUpdated(_ location: CLLocation?) {
        self.currentLatestPlayerLocation = location
        // We also need to update proximity here if ContentView is not doing it directly anymore
        // Or, ensure updatePlayerProximityToHomeBase is also called from ContentView.onChange
        if let loc = location {
            self.updatePlayerProximityToHomeBase(playerLocation: loc)
        } else {
            self.updatePlayerProximityToHomeBase(playerLocation: nil)
        }
    }
    
    // --- Centralized function to add messages ---
    func logMessage(_ text: String, type: LogMessageType) {
        // Create the new message
        let newMessage = LogMessage(text: text, type: type)
        
        // Add it to the log
        messageLog.append(newMessage)
        
        // Optional: Keep the log from getting too long (e.g., max 50 messages)
        if messageLog.count > 50 {
            messageLog.removeFirst()
        }
        
        // We can still use the toast system for important, non-spammy messages.
        if type == .rare {
            lastPotionStatusMessage = text
        }
    }
    
//    func equipItem(_ itemToEquip: ItemType) {
//        guard let slot = itemToEquip.equipmentSlot else { return } // Add 'equipmentSlot' property to ItemType
//
//        // Unequip any existing item in that slot first
//        if let currentlyEquipped = equippedGear[slot] {
//            sanctumItemStorage[currentlyEquipped, default: 0] += 1
//        }
//
//        // Equip the new item
//        sanctumItemStorage[itemToEquip, default: 0] -= 1
//        equippedGear[slot] = itemToEquip
//        
//        // Recalculate stats/capacity after equipping
//        updateTotalResourceLoads()
//        // updatePlayerStats() // A new helper function to calculate all bonuses
//    }
//
//    func unequipItem(from slot: EquipmentSlot) {
//        guard let itemToUnequip = equippedGear[slot] else { return }
//
//        // Put it back in inventory (check capacity first!)
//        // For now, assume it fits.
//        sanctumItemStorage[itemToUnequip, default: 0] += 1
//        equippedGear.removeValue(forKey: slot)
//
//        updateTotalResourceLoads()
//        // updatePlayerStats()
//    }
    
    func setHomeBase(at coordinate: CLLocationCoordinate2D) {
        let newHomeBase = HomeBase(coordinate: coordinate)
        self.homeBase = newHomeBase
        saveHomeBase()
        isSettingHomeBaseMode = false // Exit mode after setting
        print("Home Base (Sanctum) set at: \(coordinate.latitude), \(coordinate.longitude)")
    }

    // Placeholder for relocation logic
    func canRelocateHomeBase() -> Bool {
        // For now, let's say if a base exists, you can't easily relocate
        // We'll add cooldown/cost logic later
        return homeBase == nil // Only allow setting if no base exists for now for simplicity in this iteration
    }
    
    func initiateHomeBaseRelocation() {
        // This would trigger the UI for picking a new spot
        // And later, check conditions (cooldown, cost)
        if homeBase != nil { // Only if a base exists
             // For now, let's just allow re-entering the setting mode
             // In a full implementation, you'd have checks here
             print("Initiating Sanctum Relocation Process...")
             isSettingHomeBaseMode = true
        }
    }

    func updatePlayerProximityToHomeBase(playerLocation: CLLocation?) {
       guard let currentHomeBase = homeBase, let currentPlayerLocation = playerLocation else {
           if isPlayerNearHomeBase { isPlayerNearHomeBase = false } // Not near if no base or no player loc
           return
       }

       let homeBaseLocation = CLLocation(latitude: currentHomeBase.coordinate.latitude, longitude: currentHomeBase.coordinate.longitude)
       let distanceToHome = currentPlayerLocation.distance(from: homeBaseLocation)

       let newProximityState = distanceToHome <= homeBaseEnterProximity
       if isPlayerNearHomeBase != newProximityState {
           isPlayerNearHomeBase = newProximityState
           print("Player is \(isPlayerNearHomeBase ? "NEAR" : "FAR from") Home Base. Distance: \(distanceToHome)m")
       }
   }
    
    /// Checks if the user's current local time is within the 'night' period (8 PM to 6 AM).
    /// - Returns: A Boolean value, true if it is currently nighttime.
    func isNightTime() -> Bool {
        // Get the user's current calendar and the hour component from the current date.
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Night is considered from 8 PM (hour 20) up to (but not including) 6 AM (hour 6).
        // The condition is true if the hour is 20, 21, 22, 23, 0, 1, 2, 3, 4, or 5.
        let isNight = hour >= 20 || hour < 6
        
        // For debugging, you can uncomment this line to see the check in your console.
        // print("Time Check: Current hour is \(hour). Is night? \(isNight)")
        
        return isNight
    }

    // POTION USAGE AND EFFECT METHODS >>>
    func usePotion(itemType: ItemType) -> Bool {
        guard let potionEffectInfo = itemType.potionEffect else {
            print("Item \(itemType.displayName) is not a potion or has no defined effect.")
            return false
        }
        guard (sanctumItemStorage[itemType] ?? 0) > 0 else {
            print("No \(itemType.displayName) in inventory.")
            lastPotionStatusMessage = "You don't have any \(itemType.displayName) left!"
            return false
        }

        // Consume potion
        sanctumItemStorage[itemType, default: 0] -= 1
        if sanctumItemStorage[itemType, default: 0] < 0 { sanctumItemStorage[itemType] = 0 }

        // Apply effect
        let expiryTime = Date().addingTimeInterval(potionEffectInfo.duration)
        activePotionEffects[potionEffectInfo.type] = expiryTime
        
        saveActivePotionEffects() // Save immediately

        let durationMinutes = Int(potionEffectInfo.duration / 60)
        lastPotionStatusMessage = "\(itemType.displayName) consumed! Effect active for \(durationMinutes) minutes."
        print(lastPotionStatusMessage!)
        // Manually trigger objectWillChange if needed for immediate UI update of active effects list
        self.objectWillChange.send()
        return true
    }

    func checkActivePotionEffects() {
        let now = Date()
        var effectsChanged = false
        for (effectType, expiryTime) in activePotionEffects {
            if now >= expiryTime {
                activePotionEffects.removeValue(forKey: effectType)
                lastPotionStatusMessage = "\(effectType.rawValue.capitalized) effect has worn off." // Simple message
                print(lastPotionStatusMessage!)
                effectsChanged = true
            }
        }
        if effectsChanged {
            saveActivePotionEffects() // Save if any effect expired
            self.objectWillChange.send() // Notify UI
        }
    }

    // METHODS FOR CALCULATING CATEGORIZED CAPACITY AND LOAD >>>
    // This should be called by didSet of playerInventory, sanctumItemStorage, and activeBaseUpgrades
    func updateTotalResourceLoads() {
        var calculatedHerbLoad = 0
        var calculatedGeneralLoad = 0

        // 1. Calculate load from RAW RESOURCES in player's pockets.
        for (resourceType, count) in playerInventory {
            switch resourceType.category {
            case .herb: calculatedHerbLoad += count
            default: calculatedGeneralLoad += count
            }
        }
        
        // 2. NEW: Calculate load from SPARE ITEMS in player's pockets.
        // We check sanctumItemStorage for any unequipped tools/items.
        for (itemType, count) in sanctumItemStorage {
            // Only count items that are NOT currently equipped.
            if !equippedGear.values.contains(itemType) {
                // Assume each spare item takes up 10 "units" of space. We can balance this later.
                let itemWeight = 10
                calculatedGeneralLoad += (count * itemWeight)
            }
        }

        // Update the @Published properties
        if currentHerbLoad != calculatedHerbLoad { currentHerbLoad = calculatedHerbLoad }
        if currentGeneralResourceLoad != calculatedGeneralLoad { currentGeneralResourceLoad = calculatedGeneralLoad }

        // --- Recalculate Max Capacities (this part is largely the same) ---
        var newMaxHerb = baseHerbCapacity
        var newMaxGeneral = baseGeneralResourceCapacity

        if activeBaseUpgrades.contains(.basicStorehouse) {
            newMaxGeneral += 150
        }
        if let satchel = equippedGear[.satchel] {
            newMaxHerb += satchel.herbCapacityBonus
        }
        if let backpack = equippedGear[.backpack] {
            newMaxGeneral += backpack.generalResourceCapacityBonus
        }
        
        // 4. Bonus from stats (rings, etc.)
        newMaxGeneral += Int(activeStatBonuses[.generalCapacityBonus] ?? 0.0)
        newMaxHerb += Int(activeStatBonuses[.herbCapacityBonus] ?? 0.0)

        // Update the @Published properties
        if maxHerbCapacity != newMaxHerb { maxHerbCapacity = newMaxHerb }
        if maxGeneralResourceCapacity != newMaxGeneral { maxGeneralResourceCapacity = newMaxGeneral }
        
        print("Capacity Loads Updated: Herbs \(currentHerbLoad)/\(maxHerbCapacity), General \(currentGeneralResourceLoad)/\(maxGeneralResourceCapacity)")
    }
}
