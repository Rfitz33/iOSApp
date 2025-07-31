//
//  GlobalHelpers.swift
//  LocationBasedGame
//
//  Created by Reid on 7/24/25.
//
import SwiftUI
import Foundation
import CoreLocation // Make sure to import the necessary framework


// MARK: - Double Extension
extension Double {
    /// Converts a Double from radians to degrees.
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}

// MARK: - CLLocationDegrees Extension
// CLLocationDegrees is just a type alias for Double, but having a separate
// extension can be clearer for organization.
extension CLLocationDegrees {
    /// Converts CLLocationDegrees from degrees to radians.
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}

enum LogMessageType {
    case standard, success, failure, rare
    
    var color: Color {
        switch self {
        case .standard: return .white
        case .success: return .green
        case .failure: return .red
        case .rare: return .yellow
        }
    }
}

struct LogMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let type: LogMessageType
    let timestamp: Date = Date()
}

struct FeedbackEvent { let message: String; let isPositive: Bool }


// You can add other small, global helper functions or extensions here in the future.
