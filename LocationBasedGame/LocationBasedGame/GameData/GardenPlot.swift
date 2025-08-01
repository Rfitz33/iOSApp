//
//  GardenPlot.swift
//  LocationBasedGame
//
//  Created by Reid on 7/31/25.
//


// Garden.swift
import Foundation

// Represents a single plot in the player's garden
struct GardenPlot: Codable, Identifiable {
    let id: UUID // A unique ID for this specific plot instance
    var plantedSeed: ResourceType?
    var plantTime: Date?
    
    // A computed property to check if the plot is empty
    var isEmpty: Bool {
        return plantedSeed == nil
    }
    
    init() {
        self.id = UUID()
        self.plantedSeed = nil
        self.plantTime = nil
    }
}