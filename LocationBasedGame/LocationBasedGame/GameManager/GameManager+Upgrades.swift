//
//  GameManager+Upgrades.swift
//  LocationBasedGame
//
//  Created by Reid on 6/13/25.
//
import Foundation

// MARK: - Upgrades Logic
extension GameManager {
    // --- Home Base Upgrade Methods (Refactored to use BaseUpgradeType) ---
    struct UpgradeDefinition {
        let type: BaseUpgradeType
        let resources: [ResourceType: Int]?
        let components: [ComponentType: Int]?
        let prerequisites: Set<BaseUpgradeType>?
        let skillRequirements: [SkillType: Int]? // e.g., [.mining: 5, .woodcutting: 5]
        // Custom init that provides a default for prerequisites
        init(type: BaseUpgradeType,
             resources: [ResourceType: Int]? = nil, // Also good to add defaults here if applicable
             components: [ComponentType: Int]? = nil, // And here
             prerequisites: Set<BaseUpgradeType>? = nil,
             skillRequirements: [SkillType: Int]? = nil) { // Default for prerequisites
            self.type = type
            self.resources = resources
            self.components = components
            self.prerequisites = prerequisites
            self.skillRequirements = skillRequirements
        }
    }
    
    func getUpgradeDefinition(for type: BaseUpgradeType) -> UpgradeDefinition? {
            return allUpgrades.first(where: { $0.type == type })
        }

    // Check skill level prerequisites
    func canActivateUpgrade(_ upgradeType: BaseUpgradeType) -> Bool {
        guard !activeBaseUpgrades.contains(upgradeType) else { return false }
        guard let upgradeDef = getUpgradeDefinition(for: upgradeType) else { return false }

        // Skill Level Prerequisites 
        if let skillReqs = upgradeDef.skillRequirements {
            for (skill, requiredLevel) in skillReqs {
                if getLevel(for: skill) < requiredLevel {
                    return false // Player doesn't meet a skill requirement
                }
            }
        }
        if let prereqs = upgradeDef.prerequisites {
            if !prereqs.isSubset(of: activeBaseUpgrades) { return false }
        }
        // ... (resource and component cost checks - same) ...
        return true
    }

    func activateUpgrade(_ upgradeType: BaseUpgradeType) -> Bool {
        guard canActivateUpgrade(upgradeType), let upgradeDef = getUpgradeDefinition(for: upgradeType) else {
            print("Cannot activate \(upgradeType.displayName): requirements not met, already active, or not defined.")
            return false
        }

        // Deduct resources
        if let resourceCosts = upgradeDef.resources {
            for (resource, requiredAmount) in resourceCosts {
                let currentAmount = playerInventory[resource] ?? 0
                if currentAmount >= requiredAmount {
                    playerInventory[resource] = currentAmount - requiredAmount
                    if playerInventory[resource] == 0 { playerInventory.removeValue(forKey: resource) }
                } else {
                    print("Error: Insufficient \(resource.displayName) for upgrade deduction. Expected \(requiredAmount), have \(currentAmount).")
                    return false // Stop upgrade
                }
            }
        }
        
        // Deduct components
        if let componentCosts = upgradeDef.components {
            for (component, requiredAmount) in componentCosts {
                let currentAmount = sanctumComponentStorage[component] ?? 0
                // VVVV ENSURE THIS CHECK IS HERE VVVV
                if currentAmount >= requiredAmount {
                    sanctumComponentStorage[component] = currentAmount - requiredAmount
                    if sanctumComponentStorage[component] == 0 { sanctumComponentStorage.removeValue(forKey: component) }
                } else {
                    print("Error: Insufficient \(component.displayName) for upgrade deduction. Expected \(requiredAmount), have \(currentAmount).")
                    return false // Stop upgrade
                }
            }
        }
        
        activeBaseUpgrades.insert(upgradeType)
        print("\(upgradeType.displayName) activated successfully!")
        if upgradeType == .scoutsQuarters { startScoutsGatherTimer() } // Example specific action
        return true
    }
}

// Helper for clamping (add to a utility file or extension)
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
