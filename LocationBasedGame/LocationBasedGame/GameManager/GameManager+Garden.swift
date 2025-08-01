//
//  GameManager+Garden.swift
//  LocationBasedGame
//
//  Created by Reid on 7/31/25.
//


//// GameManager+Garden.swift
//import Foundation
//
//extension GameManager {
//
//    func plantSeed(_ seedType: ResourceType, inPlotID plotID: UUID) -> (success: Bool, message: String) {
//        // 1. Find the plot
//        guard let plotIndex = gardenPlots.firstIndex(where: { $0.id == plotID }) else {
//            return (false, "Could not find the garden plot.")
//        }
//        
//        // 2. Make sure it's empty
//        guard gardenPlots[plotIndex].isEmpty else {
//            return (false, "This plot is already in use.")
//        }
//        
//        // 3. Check if the player has the seed
//        guard (playerInventory[seedType] ?? 0) > 0 else {
//            return (false, "You don't have any \(seedType.displayName).")
//        }
//        
//        // 4. Consume the seed and plant it
//        playerInventory[seedType, default: 0] -= 1
//        gardenPlots[plotIndex].plantedSeed = seedType
//        gardenPlots[plotIndex].plantTime = Date()
//        
//        return (true, "Planted \(seedType.displayName)!")
//    }
//    
//    func harvestPlot(plotID: UUID) -> (success: Bool, message: String) {
//        guard let plotIndex = gardenPlots.firstIndex(where: { $0.id == plotID }) else {
//            return (false, "Could not find the garden plot.")
//        }
//        
//        guard let plantedSeed = gardenPlots[plotIndex].plantedSeed,
//              let plantTime = gardenPlots[plotIndex].plantTime,
//              let growthTime = plantedSeed.growthTime,
//              let herbToYield = plantedSeed.correspondingHerb,
//              let yieldAmount = plantedSeed.harvestYield else {
//            return (false, "There is nothing ready to harvest in this plot.")
//        }
//
//        // Check if enough time has passed
//        guard Date().timeIntervalSince(plantTime) >= growthTime else {
//            return (false, "This plant is not yet fully grown.")
//        }
//        
//        // Check for inventory space
//        guard (maxHerbCapacity - currentHerbLoad) >= yieldAmount else {
//            return (false, "Your herb satchel is too full to harvest this.")
//        }
//        
//        // Harvest the plant!
//        playerInventory[herbToYield, default: 0] += yieldAmount
//        addXP(Int(Double(herbToYield.baseXPYield) * 0.5 * Double(yieldAmount)), to: .foraging) // Grant foraging XP
//        
//        // Reset the plot
//        gardenPlots[plotIndex].plantedSeed = nil
//        gardenPlots[plotIndex].plantTime = nil
//        
//        return (true, "Harvested \(yieldAmount)x \(herbToYield.displayName)!")
//    }
//}
