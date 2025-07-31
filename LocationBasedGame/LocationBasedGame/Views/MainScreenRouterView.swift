//
//  MainScreenRouterView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/8/25.
//

import SwiftUI
import MapKit
import CoreLocation


// MainScreenRouterView.swift
struct MainScreenRouterView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var gameManager: GameManager
    
    @Binding var mapCameraPosition: MapCameraPosition
    @Binding var cameraTrackingMode: CameraTrackingMode
    
    @Binding var initialLocationSet: Bool
    @Binding var initialSpawnDone: Bool
    @Binding var showingMenuView: Bool
    @Binding var showingHomeBaseViewAsFullScreen: Bool
    @Binding var showingSetHomeBaseSheet: Bool
    
//    @State private var feedbackMessage: String? = nil
//    @State private var feedbackMessageIsPositive: Bool = true
//    @State private var feedbackTimer: Timer? = nil
//    
//    @State private var potionStatusMessage: String? = nil
//    @State private var potionStatusTimer: Timer? = nil
//    
//    @State private var levelUpEventToShow: LevelUpEvent? = nil
//    @State private var levelUpTimer: Timer? = nil
    
    @State private var previousPlayerLocation: CLLocation? = nil
    
    // --- ONE MASTER CAMERA FUNCTION ---
    private func updateCamera(animated: Bool, forMode: CameraTrackingMode) {
        var newCenter: CLLocationCoordinate2D?
        let span: MKCoordinateSpan
        
        switch forMode {
        case .player:
            guard let playerCoord = locationManager.userLocation?.coordinate else { return }
            newCenter = playerCoord
            let baseRadius = gameManager.resourceSpawnRadius
            let petBonus = gameManager.activeCreature?.type.visionBonus ?? 0.0
            let effectiveRadius = baseRadius + petBonus
            let region = MKCoordinateRegion(center: playerCoord, latitudinalMeters: effectiveRadius * 2.5, longitudinalMeters: effectiveRadius * 2.5)
            span = region.span
            
        case .homeBase:
            guard let baseCoord = gameManager.homeBase?.coordinate else { return }
            newCenter = baseCoord
            let fixedDelta = 0.003
            span = MKCoordinateSpan(latitudeDelta: fixedDelta, longitudeDelta: fixedDelta)
            
        case .none:
            return
        }
        
        guard let center = newCenter else { return }
        let newRegion = MKCoordinateRegion(center: center, span: span)
        
        if animated {
            withAnimation(.easeInOut) { mapCameraPosition = .region(newRegion) }
        } else {
            mapCameraPosition = .region(newRegion)
        }
        
        if !initialLocationSet { initialLocationSet = true }
    }
    
    var body: some View {
        // The Group and ZStack at the root handle the permission states.
        ZStack {
            switch currentScreenDisplayState {
            case .locationDisabled:
                DeviceLocationDisabledView() // Your view for when location services are off
            case .permissionNotDetermined:
                PermissionRequestView(locationManager: locationManager) // Your view to ask for permission
            case .permissionDenied:
                PermissionDeniedView() // Your view for when permission is denied
                
            case .mainGame:
                // --- This is the new HUD-based layout for the main game ---
                ZStack {
                    // Layer 1: The Map fills the entire screen, ignoring safe areas
                    // --- Map View ---
                    GameMapView(
                        gameManager: gameManager,
                        locationManager: locationManager,
                        cameraPosition: $mapCameraPosition,
                        prospectiveHomeBaseCoordinate: .constant(nil), showingHomeBaseViewAsFullScreen: $showingHomeBaseViewAsFullScreen,
                        onUserInteraction: {
                            if self.cameraTrackingMode != .none {
                                self.cameraTrackingMode = .none
                            }
                        }
                    )
                    .edgesIgnoringSafeArea(.all)
                    
                    // --- Layer 2: All Pop-up Notifications ---
//                    ZStack(alignment: .top) {
//                        // This ZStack will contain all the pop-ups and correctly position them.
//                        
//                        // Your existing toast message UI from GameMapView
//                        if let message = feedbackMessage {
//                            Text(message)
//                                .font(.callout.weight(.medium))
//                                .padding(.horizontal, 16).padding(.vertical, 10)
//                                .background(feedbackMessageIsPositive ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
//                                .foregroundColor(.white).cornerRadius(10)
//                                .shadow(radius: 5)
//                                .transition(.opacity.combined(with: .move(edge: .top)))
//                                .padding(.top, 10) // Padding from the top of its container
//                        }
//                        
//                        // Your existing potion message UI
//                        if let potionMsg = potionStatusMessage {
//                            Text(potionMsg) // ... style as before ...
//                                .transition(.opacity.combined(with: .move(edge: .top)))
//                                .padding(.top, 110) // Position below the second toast
//                        }
//                        
//                        // The Level Up View
//                        if let event = levelUpEventToShow {
//                            LevelUpView(event: event)
//                                .transition(.opacity.combined(with: .scale))
//                        }
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//                    // --- THIS PADDING IS THE FIX ---
//                    // It pushes the entire notification container down so it starts
//                    // below the TopHUDView. Adjust 85 to match your TopHUDView's height.
//                    .padding(.top, 85)
//                    .allowsHitTesting(false) // Let taps pass through to the map
//                    
                    // Layer 3: The HUD
                    // This VStack will arrange our HUD elements. It is tappable by default.
                    VStack(spacing: 0) {
    
                        // --- Top HUD ---
                        // It's aligned to the top of the ZStack automatically.
                        TopHUDView(
                            gameManager: gameManager,
                            cameraTrackingMode: $cameraTrackingMode,
                            onPlayerButtonTap: {
                                self.cameraTrackingMode = .player
                                self.updateCamera(animated: true, forMode: .player)
                            },
                            onHomeButtonTap: {
                                self.cameraTrackingMode = .homeBase
                                self.updateCamera(animated: true, forMode: .homeBase)
                            }
                        )
                        Spacer()
                            .contentShape(Rectangle()) // Defines its shape for gesture recognition
                            .allowsHitTesting(false)   // Disables taps ONLY for the spacer
                        // --- Bottom HUD ---
                        BottomHUDView(
                            gameManager: gameManager
                        )
                    }
                    .edgesIgnoringSafeArea(.all) // The HUD VStack still needs to align to the edges
                }
            }
        }
        
        // --- All modifiers now attach to the root ZStack ---
        .onAppear {
            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
        }
        .onChange(of: locationManager.userLocation) {
            let newLocation = locationManager.userLocation
            gameManager.playerLocationUpdated(newLocation)
            
            if !initialLocationSet && newLocation != nil {
                cameraTrackingMode = .player
                updateCamera(animated: true, forMode: .player)
                initialLocationSet = true
            } else if cameraTrackingMode == .player {
                updateCamera(animated: false, forMode: .player)
            }
            
            // Pet growth and spawning logic
            if let newLoc = newLocation, let oldLoc = previousPlayerLocation {
                if let activePet = gameManager.activeCreature, activePet.state == .hatchling {
                    let distance = newLoc.distance(from: oldLoc)
                    let reductionAmount = (distance / 1000.0) * 1800.0
                    if reductionAmount > 0 {
                        gameManager.petGrowthReductions[activePet.id, default: 0] += reductionAmount
                    }
                }
            }
            self.previousPlayerLocation = newLocation
            if !initialSpawnDone {
                gameManager.spawnResources(around: newLocation!.coordinate)
                initialSpawnDone = true
            } else if let oldLoc = previousPlayerLocation, newLocation!.distance(from: oldLoc) > 100 {
                gameManager.spawnResources(around: newLocation!.coordinate)
            }
        }
        .onChange(of: gameManager.activeCreatureID) {
            if cameraTrackingMode == .player {
                updateCamera(animated: true, forMode: .player)
            }
        }
//        .onReceive(gameManager.levelUpPublisher) { event in
//            levelUpTimer?.invalidate()
//            withAnimation { levelUpEventToShow = event }
//            levelUpTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
//                withAnimation(.easeOut) { levelUpEventToShow = nil }
//            }
//        }
//        .onReceive(gameManager.$lastPotionStatusMessage) { msg in
//            if let msg = msg, !msg.isEmpty {
//                potionStatusTimer?.invalidate()
//                withAnimation { potionStatusMessage = msg }
//                potionStatusTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
//                    withAnimation { potionStatusMessage = nil }
//                }
//                gameManager.lastPotionStatusMessage = nil
//            }
//        }
//        // Add this new listener for the basic feedback message
//        .onReceive(gameManager.feedbackPublisher) { feedback in
//            feedbackTimer?.invalidate()
//            withAnimation {
//                feedbackMessage = feedback.message
//                feedbackMessageIsPositive = feedback.isPositive
//            }
//            feedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { _ in
//                withAnimation { feedbackMessage = nil }
//            }
//        }
        .fullScreenCover(isPresented: $showingHomeBaseViewAsFullScreen) {
            HomeBaseView(
                gameManager: gameManager,
                locationManager: locationManager // Pass this down
            )
        }
    }
    
    // Helper for routing based on location permissions
    private var currentScreenDisplayState: ScreenDisplayState {
        if !locationManager.isLocationServicesEnabled { return .locationDisabled }
        if locationManager.authorizationStatus == .notDetermined { return .permissionNotDetermined }
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted { return .permissionDenied }
        return .mainGame
    }
    
    // The enum for states
    private enum ScreenDisplayState {
        case locationDisabled
        case permissionNotDetermined
        case permissionDenied
        case mainGame
    }
}

struct MainScreenRouterView_Previews: PreviewProvider {

    // MARK: - Mock Objects for Previewing
    
    // 1. A mock GameManager with sample data.
    class MockRouterGameManager: GameManager {
        override init() {
            super.init()
            // Give it some log messages to display
            logMessage("Gathered 5 Copper Ore!", type: .success)
            logMessage("Your scout returned with: 8x Glimmerwood.", type: .standard)
            logMessage("Too far to gather.", type: .failure)
            logMessage("Leveled up! Mining is now level 2.", type: .rare)
            logMessage("This is a much longer message to test how the text wraps inside the log view when it needs more than one line to display everything.", type: .standard)
            
            // Set a home base so the button appears
            self.homeBase = HomeBase(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
            self.isPlayerNearHomeBase = true
        }
    }
    
    // 2. A mock LocationManager.
    class MockRouterLocationManager: LocationManager {
        override init() {
            super.init()
            // Provide a sample location
            self.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
    }

    // MARK: - Preview Scenarios

    // We use a wrapper struct to manage the @State and @Binding variables.
    struct PreviewWrapper: View {
        @StateObject private var gameManager = MockRouterGameManager()
        @StateObject private var locationManager = MockRouterLocationManager()
        
        // The @State variables that MainScreenRouterView needs as bindings
        @State private var mapCameraPosition: MapCameraPosition = .automatic
        @State private var cameraTrackingMode: CameraTrackingMode = .player
        @State private var initialLocationSet = false
        @State private var initialSpawnDone = false
        @State private var showingMenuView = false
        @State private var showingHomeBaseViewAsFullScreen = false
        @State private var showingSetHomeBaseSheet = false

        var body: some View {
            MainScreenRouterView(
                locationManager: locationManager,
                gameManager: gameManager,
                mapCameraPosition: $mapCameraPosition,
                cameraTrackingMode: $cameraTrackingMode,
                initialLocationSet: $initialLocationSet,
                initialSpawnDone: $initialSpawnDone,
                showingMenuView: $showingMenuView,
                showingHomeBaseViewAsFullScreen: $showingHomeBaseViewAsFullScreen,
                showingSetHomeBaseSheet: $showingSetHomeBaseSheet
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .previewDevice("iPhone 15 Pro") // A good default device
            .previewDisplayName("Main Game UI")
    }
}
