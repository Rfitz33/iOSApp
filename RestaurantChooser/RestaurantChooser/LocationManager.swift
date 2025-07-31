//
//  LocationManager.swift
//  RestaurantChooser
//
//  Created by Reid on 5/6/25.
//


import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // Adjust accuracy as needed
    }

    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
         // Only start if authorized
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else if authorizationStatus == .notDetermined {
             requestLocationPermission() // Request if not yet determined
        }
        // Handle denied/restricted cases in the UI
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update published property with the latest location
        userLocation = locations.last
        // Often, you only need one location update for nearby search
        // stopUpdatingLocation() // Uncomment if you only need a single location fix
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        // Handle error appropriately in UI
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
         // If status changed to authorized, start updating
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
             startUpdatingLocation()
        } else {
             // Handle cases where permission might have been revoked
             userLocation = nil // Clear location if permission is lost
        }
        objectWillChange.send() // Notify views about status change
    }
}