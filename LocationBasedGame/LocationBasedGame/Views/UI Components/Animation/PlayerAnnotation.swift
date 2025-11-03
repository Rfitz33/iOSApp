//
//  PlayerAnnotation.swift
//  LocationBasedGame
//
//  Created by Reid on 10/30/25.
//


// PlayerAnnotation.swift
import Foundation
import MapKit

class PlayerAnnotation: NSObject, MKAnnotation {
    // This property is required by MKAnnotation.
    @objc dynamic var coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}