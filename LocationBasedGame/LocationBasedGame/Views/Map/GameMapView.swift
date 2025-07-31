import SwiftUI
import MapKit
import CoreLocation

// MARK: - GameMapView
struct GameMapView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    @Binding var cameraPosition: MapCameraPosition
    
    // This binding is kept for structural consistency with ContentView,
    // but its primary use for drag-to-set-base is now in SetHomeBaseSheetView.
    @Binding var prospectiveHomeBaseCoordinate: CLLocationCoordinate2D?
    @Binding var showingHomeBaseViewAsFullScreen: Bool
    
    // --- State for Toast Message ---
    @State private var feedbackMessage: String? = nil
    @State private var feedbackMessageIsPositive: Bool = true
    @State private var feedbackTimer: Timer? = nil
    
    // State for scout messages (could be combined with general feedback)
    @State private var scoutActivityMessage: String? = nil
    @State private var scoutMessageTimer: Timer? = nil
    // State for pet fetches
    @State private var nodeToFetch: ResourceNode? = nil
    
    // State for potion status messages
    @State private var potionStatusMessage: String? = nil
    @State private var potionStatusTimer: Timer? = nil
    
    var onUserInteraction: () -> Void
    
    // --- State for Player Rotation ---
    //    @State private var playerRotation: Angle = .degrees(0)
    
    // Helper Struct for a single Resource Node's Annotation View
    // (Ensure this struct is defined, either here or in a shared helper file)
    struct ResourceNodeAnnotationInnerView: View {
        let node: ResourceNode
        let onTapAction: () -> Void
        
        var body: some View {
            ZStack {
                Image(node.type.mapIconAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                
                // --- Add visual effects for special nodes ---
                if node.isDiscovery {
                    // For "Discovery" nodes from the Watchtower Scan
                    Circle()
                        .stroke(Color.yellow, lineWidth: 3)
                        .frame(width: 55, height: 55)
                        .blur(radius: 2)
                        .opacity(0.8)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .offset(x: 18, y: -18) // Position star in top-right corner
                        .shadow(radius: 2)
                    
                } else if node.isEnriched {
                    // For "Enriched" nodes from the Watchtower Aura
                    Circle()
                        .stroke(Color.cyan, lineWidth: 2)
                        .frame(width: 48, height: 48)
                        .blur(radius: 1)
                        .opacity(0.7)
                }
            }
            .padding(5)
            .background(Circle().fill(.ultraThinMaterial.opacity(0.7)))
            .shadow(radius: 1, y: 1)
            .onTapGesture(perform: onTapAction)
        }
    }
    
    var body: some View {
        MapReader { reader in // MapReader can be removed if reader parameter is not used
            ZStack(alignment: .top) { // Main ZStack for map and overlays
                // --- MAP VIEW ---
                Map(position: $cameraPosition,
                    interactionModes: [.pan, .rotate, .pitch]) {
                    
                    // --- The Pathfinder Line ---
                    // This will only draw if a discovery node is active.
                    if let discoveryID = gameManager.activeDiscoveryNodeID,
                       let discoveryNode = gameManager.activeResourceNodes.first(where: { $0.id == discoveryID }),
                       let playerLocation = locationManager.userLocation {
                        
                        // Create an array of the two points for the line.
                        let lineCoordinates = [
                            playerLocation.coordinate,
                            discoveryNode.coordinate
                        ]
                        
                        // Draw the line on the map.
                        MapPolyline(coordinates: lineCoordinates)
                            .stroke(
                                Color.yellow,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [10, 10]) // Dashed line style
                            )
                    }
                    
                    // --- Vision Radius Circle ---
                    if let userLocation = locationManager.userLocation {
                        // This circle now represents the GATHERING radius. It's constant and actionable.
                        MapCircle(center: userLocation.coordinate, radius: gameManager.gatherDistanceThreshold)
                            .foregroundStyle(Color.green.opacity(0.15)) // A green, actionable color
                            .stroke(Color.green.opacity(0.6), lineWidth: 1.5) // A more prominent stroke
                    }
                    
                    // Home Base Annotation
                    if let homeBase = gameManager.homeBase {
                        Annotation(homeBase.name, coordinate: homeBase.coordinate, anchor: .center) {
                            VStack(spacing: 4) {
                                Image("starterHome")
                                    .resizable().renderingMode(.original).aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 3)
                                
                                // Show the button only when the player is near
                                if gameManager.isPlayerNearHomeBase {
                                    Button("Enter Sanctum") {
                                        // This action will now open the full screen cover in ContentView
                                        showingHomeBaseViewAsFullScreen = true
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .background(Color.green)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                }
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                    
                    // Resource Node Annotations
                    ForEach(gameManager.activeResourceNodes) { node in
                        Annotation("\(node.type.displayName) Node", coordinate: node.coordinate, anchor: .center) {
                            ResourceNodeAnnotationInnerView(node: node) {
                                
                                guard let playerLocation = locationManager.userLocation else { return }
                                let nodeLocation = CLLocation(latitude: node.coordinate.latitude, longitude: node.coordinate.longitude)
                                let distance = playerLocation.distance(from: nodeLocation)
                                
                                // 3. Decide which action to take based on the distance.
                                if distance <= gameManager.gatherDistanceThreshold {
                                    // --- Player is IN RANGE: Perform a normal gather ---
                                    
                                    // 1. Call the top-level game logic function. It now returns an 'outcome'.
                                    let result = gameManager.gatherResourceNode(node, playerLocation: playerLocation)
                                    
                                    // 2. The UI's ONLY job is to provide haptic feedback based on the outcome.
                                    // --- THIS IS THE CORRECTED LOGIC ---
                                    switch result.outcome {
                                    case .success:
                                        // A successful action (items received) gets a success haptic.
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    case .failure:
                                        // A failed action (prey got away) gets an error haptic.
                                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    case .invalid:
                                        // An invalid action (too far, wrong tool, full inventory) gets a warning haptic.
                                        UINotificationFeedbackGenerator().notificationOccurred(.warning)
                                    }
                                    
                                } else {
                                    // --- Player is OUT OF RANGE: Attempt to show the Fetch sheet ---
                                    // We also check if a trained pet is active before showing the sheet.
                                    if let pet = gameManager.activeCreature, pet.state == .trainedAdult {
                                        // --- DYNAMIC FETCH RANGE CALCULATION FOR THE UI ---
                                        let dynamicFetchRange = gameManager.resourceSpawnRadius + pet.type.visionBonus
                                        
                                        // --- Check against the new dynamic value ---
                                        if distance <= dynamicFetchRange {
                                            // Check if the resource is a track.
                                            if node.type.isTrackType {
                                                // If it's a track, only a Dragon is allowed to fetch it.
                                                if node.type.isTrackType && pet.type != .dragon {
                                                    let message = "Too dangerous for your \(pet.type.displayName) to hunt alone."
                                                    gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                                                    gameManager.logMessage(message, type: .failure)
                                                } else {
                                                    self.nodeToFetch = node
                                                }
                                            } else {
                                                // It's not a track (wood, stone, etc.), so any pet can fetch it.
                                                self.nodeToFetch = node
                                            }
                                        } else {
                                            // The node is too far even for the pet.
                                            let message = "Too far for your companion to fetch."
                                            gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                                            gameManager.logMessage(message, type: .failure)
                                        }
                                    } else {
                                        // Player is out of range and has no trained pet active.
                                        let message = "Too far to gather."
                                        gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                                        gameManager.logMessage(message, type: .failure)
                                    }
                                }
                            }
                        }
                        .annotationTitles(.hidden)
                    }
                    
                    // Custom Player Annotation
                    if let userLocation = locationManager.userLocation {
                        Annotation("", coordinate: userLocation.coordinate, anchor: .center) {
                            Image("player_character") // Your character asset
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 64, height: 64)
                            //                                .rotationEffect(playerRotation)
                            //                                .animation(.easeInOut(duration: 0.2), value: playerRotation)
                        }
                    }
                }
                // --- MODIFIERS APPLIED DIRECTLY TO THE MAP VIEW ---
                    .mapStyle(.standard(elevation: .realistic)) // Using basic map style
                    .mapControls { MapCompass() } // Standard map controls
                // --- END OF MAP VIEW MODIFIERS ---
                
                // --- Toast Message Overlay (Child of ZStack) ---
                if let message = feedbackMessage {
                    Text(message)
                        .font(.callout.weight(.medium))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(feedbackMessageIsPositive ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                        .foregroundColor(.white).cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    // Adjust this padding for desired vertical position of the toast
                    // Position it further down, e.g., 30-35% from top, or a fixed value
                        .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + UIScreen.main.bounds.height * 0.30)
                        .frame(maxWidth: .infinity, alignment: .center) // Center horizontally
                        .allowsHitTesting(false)
                }
                // SCOUT ACTIVITY TOAST MESSAGE OVERLAY
                if let scoutMsg = scoutActivityMessage {
                    Text(scoutMsg)
                        .font(.callout.weight(.semibold)) // Slightly different font/weight
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.blue.opacity(0.85)) // Different color for scout messages
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    // Position it slightly below the gathering toast, or alternate positions
                        .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + 120) // Further down
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                }
                // POTION STATUS TOAST MESSAGE OVERLAY
                if let potionMsg = potionStatusMessage {
                    Text(potionMsg)
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Color.purple.opacity(0.85)) // Different color for potions
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    // Position it differently from other toasts, e.g., further down or alternate side
                        .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + 170) // Adjust position
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                }
            } // End of ZStack
        } // End of MapReader
        .gesture(
            DragGesture().onChanged { _ in
                onUserInteraction()
            }
            .onEnded { _ in // Also detect zoom gestures
                onUserInteraction()
            }
        )
        .onReceive(gameManager.$lastScoutMessage) { newMessage in // Listen for scout messages
            if let msg = newMessage, !msg.isEmpty {
                scoutMessageTimer?.invalidate() // Invalidate previous scout message timer
                scoutActivityMessage = msg
                scoutMessageTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
                    withAnimation(.easeInOut) {
                        scoutActivityMessage = nil
                    }
                }
                gameManager.logMessage(msg, type: .standard)
                gameManager.lastScoutMessage = nil // Clear the message in GameManager after displaying
            }
        }
        // <<< Listen for potion status messages >>>
        .onReceive(gameManager.$lastPotionStatusMessage) { newMessage in
            if let msg = newMessage, !msg.isEmpty {
                potionStatusTimer?.invalidate()
                potionStatusMessage = msg
                potionStatusTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in // Slightly shorter duration for status
                    withAnimation(.easeInOut) { potionStatusMessage = nil }
                }
                // We can check for keywords to determine the type for the log
                let type: LogMessageType = msg.lowercased().contains("found") ? .rare : .standard
                gameManager.logMessage(msg, type: type)
                
                gameManager.lastPotionStatusMessage = nil // Clear after displaying
            }
        }
        .onDisappear {
            feedbackTimer?.invalidate(); feedbackTimer = nil
            scoutMessageTimer?.invalidate(); scoutMessageTimer = nil
            potionStatusTimer?.invalidate(); potionStatusTimer = nil
        }
        .sheet(item: $nodeToFetch) { node in
            FetchConfirmationView(gameManager: gameManager, locationManager: locationManager, node: node)
        }
    }
}
    
// Preview for GameMapView
struct GameMapView_Previews: PreviewProvider {
    
    // --- Mock Objects ---
    class MockGameManagerForMapPreview: GameManager {
        override init() {
            super.init()
            self.homeBase = HomeBase(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
            self.activeResourceNodes = [
                ResourceNode(type: .T1_wood, coordinate: CLLocationCoordinate2D(latitude: 37.7759, longitude: -122.4184)),
                ResourceNode(type: .T1_herb, coordinate: CLLocationCoordinate2D(latitude: 37.7739, longitude: -122.4204)),
                ResourceNode(type: .T1_stone, coordinate: CLLocationCoordinate2D(latitude: 37.7729, longitude: -122.4174))
            ]
        }
    }
    
    class MockLocationManagerForMapPreview: LocationManager {
        override init() {
            super.init()
            let initialCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            self.userLocation = CLLocation(
                coordinate: initialCoordinate, altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5,
                course: 45.0, courseAccuracy: 10, speed: 1, speedAccuracy: 1, timestamp: Date()
            )
        }
    }
    
    // --- @State properties for the preview ---
    // These now live inside a small wrapper struct to make the preview code cleaner.
    struct PreviewWrapper: View {
        @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        ))
        @State private var prospectiveCoord: CLLocationCoordinate2D? = nil
        @State private var isShowingHomeBaseSheet = false
        
        var body: some View {
            GameMapView(
                gameManager: MockGameManagerForMapPreview(),
                locationManager: MockLocationManagerForMapPreview(),
                cameraPosition: $cameraPosition,
                prospectiveHomeBaseCoordinate: $prospectiveCoord, showingHomeBaseViewAsFullScreen: $isShowingHomeBaseSheet,
                onUserInteraction: {
                    print("Preview: User interaction detected.")
                }
            )
            .edgesIgnoringSafeArea(.all)
        }
    }

    static var previews: some View {
        // We now just call the wrapper struct.
        PreviewWrapper()
    }
}
