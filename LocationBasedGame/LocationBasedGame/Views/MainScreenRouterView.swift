import SwiftUI
import MapKit
import CoreLocation

struct MainScreenRouterView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var gameManager: GameManager
    
    // This is the source of truth for the user's INTENT
    @Binding var cameraTrackingMode: CameraTrackingMode
    
    @Binding var initialLocationSet: Bool
    @Binding var initialSpawnDone: Bool
    @Binding var showingMenuView: Bool
    @Binding var showingHomeBaseViewAsFullScreen: Bool
    @Binding var showingSetHomeBaseSheet: Bool

    @State private var previousPlayerLocation: CLLocation? = nil
    @State private var isPlayerWalking = false
    @State private var walkingStateTimer: Timer?
    
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        ZStack {
            switch currentScreenDisplayState {
            case .locationDisabled:
                DeviceLocationDisabledView()
            case .permissionNotDetermined:
                PermissionRequestView(locationManager: locationManager)
            case .permissionDenied:
                PermissionDeniedView()
            case .mainGame:
                mainGameView
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
            mapViewModel.setCameraTracking(mode: cameraTrackingMode, locationManager: locationManager, gameManager: gameManager)
        }
        .onChange(of: cameraTrackingMode) { _, newMode in
            mapViewModel.setCameraTracking(mode: newMode, locationManager: locationManager, gameManager: gameManager)
        }
        .onChange(of: locationManager.userLocation) { _, newLocation in
//            if cameraTrackingMode == .player {
//                mapViewModel.updateUserDrivenCamera(location: newLocation, heading: locationManager.heading, pet: gameManager.activeCreature, gameManager: gameManager)
//            }
            
            gameManager.playerLocationUpdated(newLocation)
            
            if !initialLocationSet, newLocation != nil {
                cameraTrackingMode = .player
                initialLocationSet = true
            }
            
            if let newLoc = newLocation, let oldLoc = previousPlayerLocation {
                let distance = newLoc.distance(from: oldLoc)
                if let activePet = gameManager.activeCreature, activePet.state == .hatchling {
                    let reductionAmount = (distance / 1000.0) * 1800.0
                    if reductionAmount > 0 { gameManager.petGrowthReductions[activePet.id, default: 0] += reductionAmount }
                }
                if distance > 1.0 {
                    if !isPlayerWalking { isPlayerWalking = true }
                    walkingStateTimer?.invalidate()
                    walkingStateTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { _ in
                        isPlayerWalking = false
                    }
                }
            }
            self.previousPlayerLocation = newLocation
            
            guard let userCurrentLocation = newLocation else { return }
            if !initialSpawnDone {
                gameManager.spawnResources(around: userCurrentLocation.coordinate)
                initialSpawnDone = true
            } else if let oldLoc = previousPlayerLocation, userCurrentLocation.distance(from: oldLoc) > 100 {
                gameManager.spawnResources(around: userCurrentLocation.coordinate)
            }
        }
//        .onChange(of: locationManager.heading) { _, newHeading in
//            if cameraTrackingMode == .player {
//                mapViewModel.updateUserDrivenCamera(location: locationManager.userLocation, heading: newHeading, pet: gameManager.activeCreature, gameManager: gameManager)
//            }
//        }
        .onChange(of: gameManager.activeCreatureID) {
            if cameraTrackingMode == .player {
                mapViewModel.updateUserDrivenCamera(location: locationManager.userLocation, heading: locationManager.heading, pet: gameManager.activeCreature, gameManager: gameManager)
            }
        }
        .onReceive(
            locationManager.$userLocation.combineLatest(locationManager.$heading)
                // This is the line that controls the delay.
                // Start with 100ms and adjust as needed.
                .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
        ) { location, heading in
            
            // This logic ensures the camera only auto-updates when in player tracking mode.
            if cameraTrackingMode == .player {
                mapViewModel.updateUserDrivenCamera(location: location, heading: heading, pet: gameManager.activeCreature, gameManager: gameManager)
            }
        }
        .fullScreenCover(isPresented: $showingHomeBaseViewAsFullScreen) {
            HomeBaseView(gameManager: gameManager, locationManager: locationManager)
        }
    }
    
    @ViewBuilder
    private var mainGameView: some View {
        ZStack {
            GameMapView(
                viewModel: mapViewModel,
                gameManager: gameManager,
                locationManager: locationManager,
                isPlayerWalking: $isPlayerWalking,
                showingHomeBaseViewAsFullScreen: $showingHomeBaseViewAsFullScreen,
                onUserInteraction: {
                    // This logic is preserved and correct.
                    if self.cameraTrackingMode != .none {
                        self.cameraTrackingMode = .none
                    }
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                TopHUDView(
                    gameManager: gameManager,
                    cameraTrackingMode: $cameraTrackingMode,
                    onPlayerButtonTap: { self.cameraTrackingMode = .player },
                    onHomeButtonTap: { self.cameraTrackingMode = .homeBase }
                )
                Spacer()
                BottomHUDView(gameManager: gameManager)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private var currentScreenDisplayState: ScreenDisplayState {
        if !locationManager.isLocationServicesEnabled { return .locationDisabled }
        if locationManager.authorizationStatus == .notDetermined { return .permissionNotDetermined }
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted { return .permissionDenied }
        return .mainGame
    }
    
    private enum ScreenDisplayState {
        case locationDisabled, permissionNotDetermined, permissionDenied, mainGame
    }
}
