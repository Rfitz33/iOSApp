//
//  HomeBase.swift
//  LocationBasedGame
//
//  Created by Reid on 5/31/25.
//


import Foundation
import CoreLocation // For CLLocationCoordinate2D

struct HomeBase: Codable, Identifiable {
    var id = UUID() // For Identifiable, useful later if we have multiple structures
    let coordinate: CLLocationCoordinate2D
    var name: String = "My Sanctum" // Default name, can be customizable later

    // This provides a convenient CLLocation object for distance calculations.
    // It is a computed property, so it doesn't need to be saved or loaded.
    var location: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    // Initializer if needed
    init(coordinate: CLLocationCoordinate2D, name: String = "My Sanctum") {
        self.coordinate = coordinate
        self.name = name
    }
}
