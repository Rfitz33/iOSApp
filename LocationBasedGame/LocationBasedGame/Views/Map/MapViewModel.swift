//
//  MapViewModel.swift
//  LocationBasedGame
//
//  Created by Reid on 10/30/25.
//


// MapViewModel.swift
import MapKit
import Combine

// This ViewModel is the new "brain" of the map. It translates SwiftUI "intent"
// into UIKit-native map state, eliminating all compiler ambiguity.
class MapViewModel: ObservableObject {
    /// The final, UIKit-native camera state that the map will display.
    @Published private(set) var camera: MKMapCamera?
    @Published private(set) var region: MKCoordinateRegion?
    
    /// Public function for SwiftUI views to call to express the user's intent.
    func setCameraTracking(mode: CameraTrackingMode, locationManager: LocationManager, gameManager: GameManager) {
        switch mode {
        case .player:
            // When tracking the player, we'll rely on the reactive updates from userLocation.
            // This call ensures an immediate update when the button is tapped.
            updateCameraForPlayerTracking(location: locationManager.userLocation,
                                          heading: locationManager.heading,
                                          pet: gameManager.activeCreature,
                                          gameManager: gameManager)
        case .homeBase:
            updateCameraForHomeBaseTracking(homeBase: gameManager.homeBase)
        case .none:
            // When tracking is off, we do nothing and let the user control the map.
            // To prevent the map from snapping back, we nil out the camera/region.
            self.camera = nil
            self.region = nil
            break
        }
    }
    
    // --- Private Logic to Translate Intent into State ---
    
    /// This function is called reactively whenever the player's location or heading changes.
    func updateUserDrivenCamera(location: CLLocation?, heading: CLHeading?, pet: Creature?, gameManager: GameManager) {
        updateCameraForPlayerTracking(location: location, heading: heading, pet: pet, gameManager: gameManager)
    }
    
    private func updateCameraForPlayerTracking(location: CLLocation?, heading: CLHeading?, pet: Creature?, gameManager: GameManager) {
        guard let location = location else { return }
        
        // This is your existing camera logic, now living in the correct place.
        let baseRadius = gameManager.resourceSpawnRadius
        let petBonus = pet?.type.visionBonus ?? 0.0
        let cameraDistance = (baseRadius + petBonus) * 4.0
        
        let newCamera = MKMapCamera(lookingAtCenter: location.coordinate,
                                    fromDistance: cameraDistance,
                                    pitch: 30,
                                    heading: heading?.magneticHeading ?? location.course)
        
        // Publish the new state for the map to consume.
        self.region = nil // Ensure we are using camera mode
        self.camera = newCamera
    }
    
    private func updateCameraForHomeBaseTracking(homeBase: HomeBase?) {
        guard let homeBase = homeBase else { return }
        
        // Your existing home base logic.
        let span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
        
        // Publish the new state.
        self.camera = nil // Ensure we are using region mode
        self.region = MKCoordinateRegion(center: homeBase.coordinate, span: span)
    }
}
