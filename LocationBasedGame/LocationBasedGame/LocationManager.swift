// LocationManager.swift
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationServicesEnabled: Bool = false
    
    // --- NEW: A @Published property to hold the compass heading ---
    @Published var heading: CLHeading? = nil
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        print("LocationManager initialized.")
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if self.isLocationServicesEnabled && (self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways) {
            manager.startUpdatingLocation()
            // --- NEW: Start updating the compass at the same time ---
            manager.startUpdatingHeading()
            print("Location and Heading updates started.")
        } else {
            print("Cannot start updates. ServicesEnabled: \(self.isLocationServicesEnabled), AuthStatus: \(self.authorizationStatus.rawValue)")
        }
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        // --- NEW: Stop updating the compass at the same time ---
        manager.stopUpdatingHeading()
        print("Location and Heading updates stopped.")
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // This is your primary state update function. It is well-structured and remains the same.
        let newAppAuthStatus = manager.authorizationStatus
        let systemServicesAreActuallyEnabled = CLLocationManager.locationServicesEnabled()
        
        DispatchQueue.main.async {
            self.authorizationStatus = newAppAuthStatus
            self.isLocationServicesEnabled = systemServicesAreActuallyEnabled
            
            print("Delegate Auth Change: AppAuth=\(self.authorizationStatus.rawValue), SystemServicesEnabled=\(self.isLocationServicesEnabled)")
            
            if self.isLocationServicesEnabled && (self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways) {
                self.startUpdatingLocation()
            } else {
                self.stopUpdatingLocation()
            }
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.userLocation = locations.last
        }
    }
    
    // --- NEW: The delegate method for heading updates ---
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            // We update our published property whenever a new heading is received.
            self.heading = newHeading
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager didFailWithError: \(error.localizedDescription)")
    }
}
