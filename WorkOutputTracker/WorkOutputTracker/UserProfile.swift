//
//  UserProfile.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/25/25.
//

import Foundation

// This struct holds the user's profile information.
struct UserProfile: Codable, Equatable {
    var name: String
    var sex: String      // "Male" or "Female"
    var height: Double   // In centimeters
    var weight: Double   // In kilograms
    var units: String    // "Metric" or "Imperial"
    var armLength: Double?   // in cm or in (use units from profile)
    var legLength: Double?
}

