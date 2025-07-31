//
//  GameManager+Persistence.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//
import Foundation

struct CreaturesState: Codable {
    var ownedCreatures: [Creature]
    var activeCreatureID: UUID?
    var petGrowthReductions: [UUID: TimeInterval]? // Make optional for backward compatibility
}

struct PassiveFeatherState: Codable {
    var lastCollectionTime: Date?
    var accumulatedFeathers: Int
}

struct WatchtowerState: Codable {
    var lastHorizonScanTime: Date?
    var activeDiscoveryNodeID: UUID?
}

// MARK: - Saving Logic
extension GameManager {
    
    func saveHomeBase() {
        if let homeBase = homeBase {
            if let encoded = try? JSONEncoder().encode(homeBase) {
                UserDefaults.standard.set(encoded, forKey: homeBaseStorageKey)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: homeBaseStorageKey) // If homeBase is nil, remove it
        }
    }

    func loadHomeBase() {
        if let savedData = UserDefaults.standard.data(forKey: homeBaseStorageKey) {
            if let decodedHomeBase = try? JSONDecoder().decode(HomeBase.self, from: savedData) {
                self.homeBase = decodedHomeBase
                print("Home Base loaded: \(String(describing: self.homeBase?.coordinate))")
                return
            }
        }
        self.homeBase = nil // Explicitly set to nil if not found or decoding fails
        print("No Home Base found in storage.")
    }
    
    // Inventory Persistence
    func saveInventory() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(playerInventory)
            UserDefaults.standard.set(encodedData, forKey:inventoryStorageKey)
        } catch {
            print("Failed to save inventory: \(error)")
        }
    }

    func loadInventory() {
        if let savedData = UserDefaults.standard.data(forKey: inventoryStorageKey) {
            do {
                let decoder = JSONDecoder()
                playerInventory = try decoder.decode([ResourceType: Int].self, from: savedData)
                print("Inventory loaded: \(playerInventory)")
            } catch {
                print("Failed to load inventory: \(error)")
                playerInventory = [:] // Reset if loading fails
            }
        } else {
            playerInventory = [:] // No saved inventory
            print("No inventory found in storage.")
        }
    }
    
    // Item Inventory Persistence
    func saveItemInventory() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(sanctumItemStorage)
            UserDefaults.standard.set(encodedData, forKey: itemInventoryStorageKey)
        } catch {
            print("Failed to save item inventory: \(error)")
        }
    }

    func loadItemInventory() {
        if let savedData = UserDefaults.standard.data(forKey: itemInventoryStorageKey) {
            do {
                let decoder = JSONDecoder()
                sanctumItemStorage = try decoder.decode([ItemType: Int].self, from: savedData)
                print("Item inventory loaded: \(sanctumItemStorage)")
            } catch {
                print("Failed to load item inventory: \(error)")
                sanctumItemStorage = [:]
            }
        } else {
            sanctumItemStorage = [:]
            print("No item inventory found in storage.")
        }
    }
        
    // Component Inventory Persistence
    func saveComponents() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(sanctumComponentStorage)
            UserDefaults.standard.set(encodedData, forKey: componentsStorageKey)
        } catch {
            print("Failed to save components: \(error)")
        }
    }
    
    func loadComponents() {
        if let savedData = UserDefaults.standard.data(forKey: componentsStorageKey) {
            do {
                let decoder = JSONDecoder()
                sanctumComponentStorage = try decoder.decode([ComponentType: Int].self, from: savedData)
                print("Components loaded: \(sanctumComponentStorage)")
            } catch {
                print("Failed to load components: \(error)")
                sanctumComponentStorage = [:]
            }
        } else {
            sanctumComponentStorage = [:]
            print("No components found in storage.")
        }
    }
    
    // --- Persistence for Tool Durability ---
    func saveToolDurability() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(currentToolDurability)
            UserDefaults.standard.set(encodedData, forKey: toolDurabilityStorageKey)
        } catch { print("Failed to save tool durability: \(error)") }
    }
    
    func loadToolDurability() {
        if let savedData = UserDefaults.standard.data(forKey: toolDurabilityStorageKey) {
            do {
                let decoder = JSONDecoder()
                currentToolDurability = try decoder.decode([ItemType: Int].self, from: savedData)
                print("Tool durability loaded: \(currentToolDurability)")
            } catch { print("Failed to load tool durability: \(error)"); currentToolDurability = [:] }
        } else { currentToolDurability = [:]; print("No tool durability found in storage.") }
    }
    
    // Persistence for Active Potion Effects
    func saveActivePotionEffects() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(activePotionEffects)
            UserDefaults.standard.set(encodedData, forKey: activePotionEffectsStorageKey)
        } catch { print("Failed to save active potion effects: \(error)") }
    }
    
    func loadActivePotionEffects() {
        if let savedData = UserDefaults.standard.data(forKey: activePotionEffectsStorageKey) {
            do {
                let decoder = JSONDecoder()
                activePotionEffects = try decoder.decode([PotionEffectType: Date].self, from: savedData)
                print("Active potion effects loaded: \(activePotionEffects)")
                // It's important to also check for expired effects right after loading,
                // in case the app was closed for longer than a potion's duration.
                checkActivePotionEffects()
            } catch { print("Failed to load active potion effects: \(error)"); activePotionEffects = [:] }
        } else { activePotionEffects = [:]; print("No active potion effects found in storage.") }
    }
    
    // Skill State Persistence
    func saveSkillsState() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(playerSkillsXP) // Only save XP
            UserDefaults.standard.set(encodedData, forKey: skillsStorageKey)
        } catch {
            print("Failed to save skills state: \(error)")
        }
    }
    
    func loadSkillsState() {
        if let savedData = UserDefaults.standard.data(forKey: skillsStorageKey) {
            do {
                let decoder = JSONDecoder()
                playerSkillsXP = try decoder.decode([SkillType: Int].self, from: savedData)
                print("Skills XP loaded: \(playerSkillsXP)")
            } catch {
                print("Failed to load skills state: \(error)")
                playerSkillsXP = [:]
            }
        } else {
            playerSkillsXP = [:]
            print("No skills state found in storage.")
        }
        // Levels will be recalculated from XP in init after loading
    }
    
    // Persistence for Base Upgrade States (now saves a Set of BaseUpgradeType)
    func saveBaseUpgradesState() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(activeBaseUpgrades) // Save the Set
            UserDefaults.standard.set(encodedData, forKey: baseUpgradesStorageKey)
        } catch { print("Failed to save base upgrades state: \(error)") }
    }
    
    func loadBaseUpgradesState() {
        if let savedData = UserDefaults.standard.data(forKey: baseUpgradesStorageKey) {
            do {
                let decoder = JSONDecoder()
                activeBaseUpgrades = try decoder.decode(Set<BaseUpgradeType>.self, from: savedData) // Load the Set
                print("Base upgrades state loaded: \(activeBaseUpgrades.map { $0.displayName })")
            } catch { print("Failed to load base upgrades state: \(error)"); activeBaseUpgrades = [] }
        } else { activeBaseUpgrades = []; print("No base upgrades state found in storage.") }
    }
    
    // Persistence for Scout State
    func saveScoutState() {
        do {
            let encoder = JSONEncoder()
            // Save assignedScoutTask (it's optional ResourceType, which is RawRepresentable by String)
            let data = try encoder.encode(assignedScoutTask)
            UserDefaults.standard.set(data, forKey: scoutStateStorageKey)
        } catch {
            print("Failed to save scout state: \(error)")
        }
    }
    
    func loadScoutState() {
        if let savedData = UserDefaults.standard.data(forKey: scoutStateStorageKey) {
            do {
                let decoder = JSONDecoder()
                assignedScoutTask = try decoder.decode(ResourceType?.self, from: savedData)
                print("Scout state loaded. Assigned task: \(assignedScoutTask?.displayName ?? "None")")
            } catch {
                print("Failed to load scout state: \(error)")
                assignedScoutTask = nil
            }
        } else {
            assignedScoutTask = nil // Default to no assignment
            print("No scout state found in storage.")
        }
    }

    func savePassiveFeatherState() {
        let state = PassiveFeatherState(lastCollectionTime: lastFeatherCollectionTime, accumulatedFeathers: accumulatedFeathers)
        if let encodedData = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(encodedData, forKey: passiveFeatherStateKey)
        }
    }

    func loadPassiveFeatherState() {
        if let savedData = UserDefaults.standard.data(forKey: passiveFeatherStateKey) {
            if let decodedState = try? JSONDecoder().decode(PassiveFeatherState.self, from: savedData) {
                self.lastFeatherCollectionTime = decodedState.lastCollectionTime
                self.accumulatedFeathers = decodedState.accumulatedFeathers
            }
        }
    }

    
    // --- NEW: Persistence for Aviary Data ---
        
    func saveCreaturesState() {
        // Create an instance of our new struct with the current state.
        // Pass the new dictionary to the state object
        let stateToSave = CreaturesState(
            ownedCreatures: self.ownedCreatures,
            activeCreatureID: self.activeCreatureID,
            petGrowthReductions: self.petGrowthReductions
        )
        do {
            // Encode the struct instance. This will work correctly.
            let encodedData = try JSONEncoder().encode(stateToSave)
            UserDefaults.standard.set(encodedData, forKey: creaturesStorageKey)
        } catch {
            print("Failed to save creatures state: \(error)")
        }
    }

    // --- MODIFIED FUNCTION ---
    func loadCreaturesState() {
        if let savedData = UserDefaults.standard.data(forKey: creaturesStorageKey) {
            do {
                let decodedState = try JSONDecoder().decode(CreaturesState.self, from: savedData)
                self.ownedCreatures = decodedState.ownedCreatures
                self.activeCreatureID = decodedState.activeCreatureID
                // Load the reductions, providing an empty dict if it's nil from an old save
                self.petGrowthReductions = decodedState.petGrowthReductions ?? [:]
                print("Creatures state loaded: \(ownedCreatures.count) creatures, active ID: \(activeCreatureID?.uuidString ?? "None")")
            } catch {
                print("Failed to load creatures state: \(error)")
                self.ownedCreatures = []
                self.activeCreatureID = nil
            }
        }
    }
    
    func saveIncubationState() {
        do {
            let encodedData = try JSONEncoder().encode(incubatingSlots)
            UserDefaults.standard.set(encodedData, forKey: incubationStorageKey)
        } catch {
            print("Failed to save incubation state: \(error)")
        }
    }

    func loadIncubationState() {
        if let savedData = UserDefaults.standard.data(forKey: incubationStorageKey) {
            do {
                self.incubatingSlots = try JSONDecoder().decode([IncubationSlot].self, from: savedData)
                print("Incubation state loaded: \(incubatingSlots.count) eggs incubating.")
            } catch {
                print("Failed to load incubation state: \(error)")
                self.incubatingSlots = []
            }
        }
    }
    
    func saveUnlockedPetTypes() {
        do {
            let encodedData = try JSONEncoder().encode(unlockedPetTypes)
            UserDefaults.standard.set(encodedData, forKey: unlockedPetTypesKey)
        } catch {
            print("Failed to save unlocked pet types: \(error)")
        }
    }

    func loadUnlockedPetTypes() {
        if let savedData = UserDefaults.standard.data(forKey: unlockedPetTypesKey) {
            do {
                unlockedPetTypes = try JSONDecoder().decode(Set<CreatureType>.self, from: savedData)
                print("Loaded unlocked pet types: \(unlockedPetTypes.map { $0.displayName })")
            } catch {
                print("Failed to load unlocked pet types: \(error)")
                unlockedPetTypes = []
            }
        }
    }
    
    func saveWatchtowerState() {
        let state = WatchtowerState(
            lastHorizonScanTime: self.lastHorizonScanTime,
            activeDiscoveryNodeID: self.activeDiscoveryNodeID
        )
        
        do {
            let encodedData = try JSONEncoder().encode(state)
            UserDefaults.standard.set(encodedData, forKey: watchtowerStateKey)
        } catch {
            print("Failed to save Watchtower state: \(error)")
        }
    }

    func loadWatchtowerState() {
        if let savedData = UserDefaults.standard.data(forKey: watchtowerStateKey) {
            do {
                let decodedState = try JSONDecoder().decode(WatchtowerState.self, from: savedData)
                self.lastHorizonScanTime = decodedState.lastHorizonScanTime
                self.activeDiscoveryNodeID = decodedState.activeDiscoveryNodeID
                print("Watchtower state loaded. Last scan: \(lastHorizonScanTime ?? Date.distantPast)")
            } catch {
                print("Failed to load Watchtower state: \(error)")
                // Reset to default values if decoding fails
                self.lastHorizonScanTime = nil
                self.activeDiscoveryNodeID = nil
            }
        }
    }
}
