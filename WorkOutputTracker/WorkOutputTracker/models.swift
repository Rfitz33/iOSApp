//
//  models.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/25/25.
//

import Foundation

struct MovementEntry: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var weight: Double   // in kg (use lbs and convert if user prefers imperial)
    var reps: Int        // reps per round or per set
    var distance: Double // in meters (or feet and convert)
}

enum WorkoutType: String, CaseIterable, Identifiable {
    case amrap = "AMRAP"
    case forTime = "For time"
    case forWeight = "For weight"
    case emom = "EMOM"
    case tabata = "Tabata"
    case forDistance = "For distance"
    case notTimed = "Not timed"
    
    var id: String { self.rawValue }
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .amrap: return "repeat"
        case .forTime: return "timer"
        case .forWeight: return "scalemass"
        case .emom: return "clock"
        case .tabata: return "stopwatch"
        case .forDistance: return "location"
        case .notTimed: return "minus.circle"
        }
    }
    
    var description: String {
        switch self {
        case .amrap: return "As many rounds/reps as possible"
        case .forTime: return "Complete the workout as fast as possible"
        case .forWeight: return "Maximize total load lifted"
        case .emom: return "Every minute on the minute"
        case .tabata: return "Intervals of 20s work/10s rest"
        case .forDistance: return "Complete a set distance"
        case .notTimed: return "Not tracked for time/power"
        }
    }
}
