//
//  GameManager+Garden.swift
//  LocationBasedGame
//
//  Created by Reid on 7/31/25.
//


// GameManager+Garden.swift
//import Foundation
//
//// MARK: - Garden Logic
//extension GameManager {
//
//    // --- PLANTING LOGIC ---
//    func plantSeed(_ seedType: ResourceType, inPlotID plotID: UUID) -> (success: Bool, message: String) {
//        guard let plotIndex = gardenPlots.firstIndex(where: { $0.id == plotID }) else {
//            return (false, "Could not find the garden plot.")
//        }
//        
//        guard gardenPlots[plotIndex].isEmpty else {
//            return (false, "This plot is already in use.")
//        }
//        
//        guard (playerInventory[seedType] ?? 0) > 0 else {
//            return (false, "You don't have any \(seedType.displayName).")
//        }
//        
//        playerInventory[seedType, default: 0] -= 1
//        gardenPlots[plotIndex].plantedSeed = seedType
//        gardenPlots[plotIndex].plantTime = Date()
//        
//        return (true, "Planted \(seedType.displayName)!")
//    }
//    
//    // --- HARVESTING LOGIC ---
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
//        guard Date().timeIntervalSince(plantTime) >= growthTime else {
//            return (false, "This plant is not yet fully grown.")
//        }
//        
//        guard (maxHerbCapacity - currentHerbLoad) >= yieldAmount else {
//            return (false, "Your herb satchel is too full to harvest this.")
//        }
//        
//        playerInventory[herbToYield, default: 0] += yieldAmount
//        // Grant Foraging XP for the harvest, scaled by the yield.
//        addXP(Int(Double(herbToYield.baseXPYield) * 0.5 * Double(yieldAmount)), to: .foraging)
//        
//        // Reset the plot to be empty again.
//        gardenPlots[plotIndex].plantedSeed = nil
//        gardenPlots[plotIndex].plantTime = nil
//        
//        return (true, "Harvested \(yieldAmount)x \(herbToYield.displayName)!")
//    }
//}
