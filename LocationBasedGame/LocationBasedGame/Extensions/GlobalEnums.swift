//
//  GlobalEnums.swift
//  LocationBasedGame
//
//  Created by Reid on 7/27/25.
//


// GlobalEnums.swift
import Foundation

// This enum is now globally accessible.
enum ActiveSheet: Identifiable {
    case player, stats, skills, sanctum, companions, settings
    
    var id: Self { self }
    
    // --- NEW: Add the iconName property here ---
    var iconName: String {
        switch self {
        case .player: return "hud_icon_player"
        case .stats: return "hud_icon_stats"
        case .skills: return "hud_icon_skills"
        case .sanctum: return "hud_icon_sanctum"
        case .companions: return "hud_icon_companions"
        case .settings: return "hud_icon_settings"
        }
    }
}

enum GatheringOutcome {
    case success            // Action succeeded, items were awarded.
    case failure            // Action was attempted but failed (e.g., prey got away).
    case invalid            // Action could not be attempted (too far, wrong tool, etc.).
}
