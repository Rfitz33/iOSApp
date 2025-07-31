import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    @Published var isLocationServicesEnabled: Bool = false
    
    override init() {
        super.init() // Call super.init() first
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        print("LocationManager initialized. Waiting for delegate callbacks.")
    }
    
    func requestLocationPermission() {
        if !self.isLocationServicesEnabled {
            
            print("Attempting to request permission, but local isLocationServicesEnabled is false.")
        }
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        // Check our locally cached states
        if self.isLocationServicesEnabled &&
            (self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways) {
            manager.startUpdatingLocation()
            print("Location updates started (based on local state).")
        } else {
            print("Cannot start updating location. Local Services Enabled: \(self.isLocationServicesEnabled), Local Auth Status: \(self.authorizationStatus.rawValue)")
        }
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        print("Location updates stopped.")
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // This is THE primary place to update our state variables.
        let newAppAuthStatus = manager.authorizationStatus // Get app's authorization from the manager instance
        // Static analyzer may warn on the next line. If app functions correctly,
        // document and accept if this is the only remaining instance of the warning.
        let systemServicesAreActuallyEnabled = CLLocationManager.locationServicesEnabled() // Check system setting HERE
        
        var didChange = false
        if self.authorizationStatus != newAppAuthStatus {
            self.authorizationStatus = newAppAuthStatus
            didChange = true
        }
        if self.isLocationServicesEnabled != systemServicesAreActuallyEnabled {
            self.isLocationServicesEnabled = systemServicesAreActuallyEnabled
            didChange = true
        }
        
        DispatchQueue.main.async {
            if didChange || self.authorizationStatus == .notDetermined { // Force update if still not determined
                // Update local state if it actually changed
                if self.authorizationStatus != newAppAuthStatus { self.authorizationStatus = newAppAuthStatus }
                if self.isLocationServicesEnabled != systemServicesAreActuallyEnabled { self.isLocationServicesEnabled = systemServicesAreActuallyEnabled }
                
                print("Delegate Auth Change: AppAuth=\(self.authorizationStatus.rawValue), SystemServicesEnabled=\(self.isLocationServicesEnabled)")
            }
            
            if self.isLocationServicesEnabled &&
                (self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways) {
                self.startUpdatingLocation()
            } else {
                self.stopUpdatingLocation()
                if !self.isLocationServicesEnabled {
                    print("Delegate Stop: System Location Services are OFF.")
                }
                if self.authorizationStatus == .denied || self.authorizationStatus == .restricted {
                    print("Delegate Stop: App Location access DENIED or RESTRICTED.")
                } else if self.authorizationStatus == .notDetermined && self.isLocationServicesEnabled {
                    // This state means system services are on, but app hasn't been authorized yet.
                    // UI should be showing permission request.
                    print("Delegate Stop: App Location access NOT DETERMINED (but services are ON).")
                    }
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            DispatchQueue.main.async {
                self.userLocation = locations.last
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location Manager didFailWithError: \(error.localizedDescription)")
            // It's possible that if system services are turned off after granting permission,
            // this error might be triggered. Re-check status.
            DispatchQueue.main.async { // Ensure UI updates triggered by this are on main
                if let clError = error as? CLError, clError.code == .denied {
                    print("didFailWithError: CLError.denied received. ExpectingDidChangeAuthorization to update state.")
                }
            }
        }
    }
