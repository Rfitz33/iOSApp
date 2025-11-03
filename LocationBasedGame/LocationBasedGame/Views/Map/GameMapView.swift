import SwiftUI
import MapKit
import CoreLocation

// MARK: - GameMapView
struct GameMapView: View {
    @ObservedObject var viewModel: MapViewModel
    
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    @Binding var isPlayerWalking: Bool
    @Binding var showingHomeBaseViewAsFullScreen: Bool
    
//    @Binding var prospectiveHomeBaseCoordinate: CLLocationCoordinate2D?
    
    @State private var playerAnnotation = PlayerAnnotation(coordinate: kCLLocationCoordinate2DInvalid)
    @State private var nodeToFetch: ResourceNode? = nil
    var onUserInteraction: () -> Void
    // Needed?
//    @Binding var cameraPosition: MapCameraPosition
//    let currentMapHeading: CLLocationDirection
    // ----------
    
    // --- State for Toasts ---
    @State private var feedbackMessage: String? = nil
    @State private var feedbackMessageIsPositive: Bool = true
    @State private var feedbackTimer: Timer? = nil
    
    @State private var scoutActivityMessage: String? = nil
    @State private var scoutMessageTimer: Timer? = nil
    
    @State private var potionStatusMessage: String? = nil
    @State private var potionStatusTimer: Timer? = nil
    
    
    
    var body: some View {
        ZStack(alignment: .top) {
            MapViewRepresentable(
                viewModel: viewModel,
                isPlayerWalking: $isPlayerWalking,
                showingHomeBaseViewAsFullScreen: $showingHomeBaseViewAsFullScreen,
                gameManager: gameManager, // Pass necessary objects through
                playerAnnotation: playerAnnotation,
                onUserInteraction: onUserInteraction,
                nodeTapAction: handleNodeTap
            )
            .edgesIgnoringSafeArea(.all)
            
            // --- OVERLAYS ---
            toastOverlays
        }
        .onReceive(locationManager.$userLocation) { newLocation in
            guard let newCoordinate = newLocation?.coordinate else { return }
            if !CLLocationCoordinate2DIsValid(playerAnnotation.coordinate) {
                playerAnnotation.coordinate = newCoordinate
            } else {
                UIView.animate(withDuration: 1.0, delay: 0, options: [.curveLinear, .allowUserInteraction]) {
                    playerAnnotation.coordinate = newCoordinate
                }
            }
        }
        .onReceive(gameManager.$lastScoutMessage, perform: handleScoutMessage)
        .onReceive(gameManager.$lastPotionStatusMessage, perform: handlePotionMessage)
        .onDisappear(perform: clearAllTimers)
        .sheet(item: $nodeToFetch) { node in
            FetchConfirmationView(gameManager: gameManager, locationManager: locationManager, node: node)
        }
    }
    
    // --- Extracted Views and Logic for Clarity ---
    
    @ViewBuilder
    private var toastOverlays: some View {
        if let message = feedbackMessage {
            toastView(message: message, isPositive: feedbackMessageIsPositive, yOffset: UIScreen.main.bounds.height * 0.30)
        }
        if let scoutMsg = scoutActivityMessage {
            toastView(message: scoutMsg, color: .blue, yOffset: 120)
        }
        if let potionMsg = potionStatusMessage {
            toastView(message: potionMsg, color: .purple, yOffset: 170)
        }
    }
    
    private func toastView(message: String, isPositive: Bool, yOffset: CGFloat) -> some View {
        Text(message)
            .font(.callout.weight(.medium))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background((isPositive ? Color.green : Color.red).opacity(0.9))
            .foregroundColor(.white).cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + yOffset)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(false)
    }
    
    private func toastView(message: String, color: Color, yOffset: CGFloat) -> some View {
        Text(message)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(color.opacity(0.85))
            .foregroundColor(.white).cornerRadius(10)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .padding(.top, (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets.top ?? 0 + yOffset)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(false)
    }

    private func handleNodeTap(node: ResourceNode) {
        guard let playerLocation = locationManager.userLocation else { return }
        let nodeLocation = CLLocation(latitude: node.coordinate.latitude, longitude: node.coordinate.longitude)
        let distance = playerLocation.distance(from: nodeLocation)
        
        if distance <= gameManager.gatherDistanceThreshold {
            let result = gameManager.gatherResourceNode(node, playerLocation: playerLocation)
            switch result.outcome {
            case .success: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .failure: UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .invalid: UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
        } else {
            if let pet = gameManager.activeCreature, pet.state == .trainedAdult {
                let dynamicFetchRange = gameManager.resourceSpawnRadius + pet.type.visionBonus
                if distance <= dynamicFetchRange {
                    if node.type.isTrackType && pet.type != .dragon {
                        let message = "Too dangerous for your \(pet.type.displayName) to hunt alone."
                        gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                        gameManager.logMessage(message, type: .failure)
                    } else { self.nodeToFetch = node }
                } else {
                    let message = "Too far for your companion to fetch."
                    gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                    gameManager.logMessage(message, type: .failure)
                }
            } else {
                let message = "Too far to gather."
                gameManager.feedbackPublisher.send(FeedbackEvent(message: message, isPositive: false))
                gameManager.logMessage(message, type: .failure)
            }
        }
    }
    
    private func handleScoutMessage(_ newMessage: String?) {
        if let msg = newMessage, !msg.isEmpty {
            scoutMessageTimer?.invalidate()
            scoutActivityMessage = msg
            scoutMessageTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { _ in
                withAnimation(.easeInOut) { scoutActivityMessage = nil }
            }
            gameManager.logMessage(msg, type: .standard)
            gameManager.lastScoutMessage = nil
        }
    }
    
    private func handlePotionMessage(_ newMessage: String?) {
        if let msg = newMessage, !msg.isEmpty {
            potionStatusTimer?.invalidate()
            potionStatusMessage = msg
            potionStatusTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                withAnimation(.easeInOut) { potionStatusMessage = nil }
            }
            let type: LogMessageType = msg.lowercased().contains("found") ? .rare : .standard
            gameManager.logMessage(msg, type: type)
            gameManager.lastPotionStatusMessage = nil
        }
    }
    
    private func clearAllTimers() {
        feedbackTimer?.invalidate(); feedbackTimer = nil
        scoutMessageTimer?.invalidate(); scoutMessageTimer = nil
        potionStatusTimer?.invalidate(); potionStatusTimer = nil
    }
}

// MARK: - MapViewRepresentable
private struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel
    @Binding var isPlayerWalking: Bool
    @Binding var showingHomeBaseViewAsFullScreen: Bool
    @ObservedObject var gameManager: GameManager
    var playerAnnotation: PlayerAnnotation
    var onUserInteraction: () -> Void
    var nodeTapAction: (ResourceNode) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        
        let compass = MKCompassButton(mapView: mapView)
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        mapView.addSubview(compass)
        mapView.addSubview(trackingButton)
        
        compass.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            compass.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 10),
            compass.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            trackingButton.topAnchor.constraint(equalTo: compass.bottomAnchor, constant: 10),
            trackingButton.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        mapView.showsUserLocation = false
        mapView.register(PlayerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PlayerAnnotationView.reuseID)
        mapView.register(HostingAnnotationView<AnyView>.self, forAnnotationViewWithReuseIdentifier: "home")
        mapView.register(HostingAnnotationView<ResourceNodeAnnotationInnerView>.self, forAnnotationViewWithReuseIdentifier: "res")
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        
        if let camera = viewModel.camera {
            if mapView.camera != camera { mapView.setCamera(camera, animated: true) }
        } else if let region = viewModel.region {
            if mapView.region != region { mapView.setRegion(region, animated: true) }
        }
        
        // This is now the single source of truth for all annotation states
        context.coordinator.syncAllAnnotations(to: mapView)
        
        if let playerView = mapView.view(for: playerAnnotation) as? PlayerAnnotationView {
            if isPlayerWalking {
                playerView.startWalkingAnimation()
            } else {
                playerView.setToIdle()
            }
        }
        
        context.coordinator.syncOverlays(to: mapView)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        init(_ parent: MapViewRepresentable) { self.parent = parent }
        
        // --- THE FIX: A single, robust function to sync ALL annotations ---
        func syncAllAnnotations(to mapView: MKMapView) {
            // 1. Sync the Player
            syncPlayerAnnotation(to: mapView)
            
            // 2. Sync all other game annotations (nodes, home base)
            let otherAnns = mapView.annotations.filter { !($0 is PlayerAnnotation) }
            var newAnns: [MKAnnotation] = []
            newAnns.append(contentsOf: parent.gameManager.activeResourceNodes.map { ResourceAnnotation(node: $0) })
            if let home = parent.gameManager.homeBase {
                newAnns.append(HomeBaseAnnotation(homeBase: home))
            }
            let (toRemove, toAdd) = diffAnnotations(current: otherAnns, new: newAnns)
            if !toRemove.isEmpty { mapView.removeAnnotations(toRemove) }
            if !toAdd.isEmpty { mapView.addAnnotations(toAdd) }
        }
        
        // --- This new helper function solves the race condition ---
        private func syncPlayerAnnotation(to mapView: MKMapView) {
            let playerAnn = parent.playerAnnotation
            // Check if the player annotation is already on the map
            let isPlayerOnMap = mapView.annotations.contains(where: { $0 is PlayerAnnotation })
            
            // If the player coordinate is valid...
            if CLLocationCoordinate2DIsValid(playerAnn.coordinate) {
                // ...and they are NOT on the map, add them.
                if !isPlayerOnMap {
                    mapView.addAnnotation(playerAnn)
                }
            }
            // If the player coordinate is NOT valid...
            else {
                // ...and they ARE on the map, remove them.
                if isPlayerOnMap {
                    if let existing = mapView.annotations.first(where: { $0 is PlayerAnnotation }) {
                        mapView.removeAnnotation(existing)
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // This implementation is now correct and final
            if annotation is PlayerAnnotation {
                return mapView.dequeueReusableAnnotationView(withIdentifier: PlayerAnnotationView.reuseID, for: annotation)
            }
            else if let resAnn = annotation as? ResourceAnnotation {
                let reuseID = "res"
                let view: HostingAnnotationView<GameMapView.ResourceNodeAnnotationInnerView>
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? HostingAnnotationView<GameMapView.ResourceNodeAnnotationInnerView> {
                    view = dequeuedView
                    view.annotation = annotation
                } else {
                    view = HostingAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                }
                view.set(rootView: GameMapView.ResourceNodeAnnotationInnerView(node: resAnn.node, onTapAction: {}))
                return view
            }
            else if let homeAnn = annotation as? HomeBaseAnnotation {
                let reuseID = "home"
                typealias HomeAnnotationContentView = AnyView
                let view: HostingAnnotationView<HomeAnnotationContentView>
                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? HostingAnnotationView<HomeAnnotationContentView> {
                    view = dequeuedView
                    view.annotation = annotation
                } else {
                    view = HostingAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                }
                view.set(rootView: AnyView(homeAnnotationView(for: homeAnn)))
                return view
            }
            return nil
        }
        
        // Helper to construct the home annotation's SwiftUI view
        @ViewBuilder
        private func homeAnnotationView(for annotation: HomeBaseAnnotation) -> some View {
            VStack(spacing: 4) {
                Image("starterHome")
                    .resizable().renderingMode(.original).aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60).shadow(radius: 3)
                if parent.gameManager.isPlayerNearHomeBase {
                    Button("Enter Sanctum") {
                        // **FIXED**: This now correctly accesses the binding
                        self.parent.showingHomeBaseViewAsFullScreen = true
                    }
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .font(.caption.bold()).foregroundColor(.white)
                    .background(Color.green).cornerRadius(8).shadow(radius: 2)
                }
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.green.withAlphaComponent(0.15)
                renderer.strokeColor = UIColor.green.withAlphaComponent(0.6)
                renderer.lineWidth = 1.5
                return renderer
            } else if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .yellow
                renderer.lineWidth = 3
                renderer.lineDashPattern = [10, 10]
                renderer.lineCap = .round
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            if let resAnn = view.annotation as? ResourceAnnotation {
                parent.nodeTapAction(resAnn.node)
            }
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
             let view = mapView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
             if view?.isDragging == true { parent.onUserInteraction() }
        }
        
        func syncAnnotations(to mapView: MKMapView) {
            // Get the current annotations from the map, excluding the player which is managed separately.
            let currentAnns = mapView.annotations.filter { !($0 is PlayerAnnotation) }
            
            // Build the list of new annotations that *should* be on the map from the game state.
            var newAnns: [MKAnnotation] = []
            
            // Add all active resource nodes.
            newAnns.append(contentsOf: parent.gameManager.activeResourceNodes.map { ResourceAnnotation(node: $0) })
            
            // Add the home base if it exists.
            if let home = parent.gameManager.homeBase {
                newAnns.append(HomeBaseAnnotation(homeBase: home))
            }
            
            // Use our helper function to efficiently find what has changed.
            let (toRemove, toAdd) = diffAnnotations(current: currentAnns, new: newAnns)
            
            // Apply the changes to the map. This prevents flickering.
            if !toRemove.isEmpty {
                mapView.removeAnnotations(toRemove)
            }
            if !toAdd.isEmpty {
                mapView.addAnnotations(toAdd)
            }
        }

        func syncOverlays(to mapView: MKMapView) {
            // For overlays, the "remove all, add all" pattern is simple and robust.
            mapView.removeOverlays(mapView.overlays)
            
            var newOverlays: [MKOverlay] = []
            
            // Use the exact property name you provided from your GameManager.
            if let userLoc = parent.gameManager.currentLatestPlayerLocation {
                
                // 1. Re-add the Vision Radius Circle
                newOverlays.append(MKCircle(center: userLoc.coordinate, radius: parent.gameManager.gatherDistanceThreshold))
                
                // 2. Re-add the Pathfinder Polyline if a discovery node is active.
                if let discoveryID = parent.gameManager.activeDiscoveryNodeID,
                   let target = parent.gameManager.activeResourceNodes.first(where: { $0.id == discoveryID }) {
                    newOverlays.append(MKPolyline(coordinates: [userLoc.coordinate, target.coordinate], count: 2))
                }
            }
            
            // Add the newly created overlays to the map.
            if !newOverlays.isEmpty {
                mapView.addOverlays(newOverlays)
            }
        }

        private func diffAnnotations(current: [MKAnnotation], new: [MKAnnotation]) -> (remove: [MKAnnotation], add: [MKAnnotation]) {
            // Use the IdentifiableAnnotation protocol we created to get unique IDs for each annotation.
            let currentIDs = Set(current.compactMap { ($0 as? any IdentifiableAnnotation)?.uniqueID })
            let newIDs = Set(new.compactMap { ($0 as? any IdentifiableAnnotation)?.uniqueID })

            // Find annotations to remove: their ID is in the current set on the map, but not in the new set from the game state.
            let toRemove = current.filter { annotation in
                guard let identifiable = annotation as? any IdentifiableAnnotation else {
                    return true // A failsafe: remove any old, non-identifiable annotations.
                }
                return !newIDs.contains(identifiable.uniqueID)
            }

            // Find annotations to add: their ID is in the new set from the game state, but not in the current set on the map.
            let toAdd = new.filter { annotation in
                guard let identifiable = annotation as? any IdentifiableAnnotation else {
                    return false // Don't add non-identifiable annotations.
                }
                return !currentIDs.contains(identifiable.uniqueID)
            }

            return (toRemove, toAdd)
        }
    }
}

// MARK: - Helper Annotation Classes & Protocols
protocol IdentifiableAnnotation: MKAnnotation { var uniqueID: String { get } }
class ResourceAnnotation: NSObject, IdentifiableAnnotation {
    let node: ResourceNode
    var coordinate: CLLocationCoordinate2D { node.coordinate }
    var uniqueID: String { node.id.uuidString }
    init(node: ResourceNode) { self.node = node }
}
class HomeBaseAnnotation: NSObject, IdentifiableAnnotation {
    let homeBase: HomeBase
    var coordinate: CLLocationCoordinate2D { homeBase.coordinate }
    var uniqueID: String { "HOME_BASE" }
    init(homeBase: HomeBase) { self.homeBase = homeBase }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}

// MARK: - Helper Inner Views
struct ResourceNodeAnnotationInnerView: View {
    let node: ResourceNode
    let onTapAction: () -> Void
    
    var body: some View {
        ZStack {
            // Base icon for the resource node
            Image(node.type.mapIconAssetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            // --- Visual effects for special node types ---
            
            // Yellow glowing effect for "Discovery" nodes
            if node.isDiscovery {
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
            }
            // Cyan glowing effect for "Enriched" nodes
            else if node.isEnriched {
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
        // Note: The primary tap gesture is now handled by the map view's delegate
        // for better performance and reliability. This .onTapGesture is redundant
        // but harmless. It could be useful for SwiftUI Previews.
        // .onTapGesture(perform: onTapAction)
    }
}

extension GameMapView {
    struct ResourceNodeAnnotationInnerView: View {
        let node: ResourceNode
        // The onTapAction is no longer strictly needed since the delegate handles taps,
        // but we can keep it for potential future use or previews.
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
        }
    }
}
