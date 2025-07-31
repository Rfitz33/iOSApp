//
//  SetHomeBaseSheetView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//


import SwiftUI
import MapKit
import CoreLocation

// MARK: - SetHomeBaseSheetView
struct SetHomeBaseSheetView: View {
    @Binding var isPresented: Bool // To dismiss this sheet
    
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    
    let fixedLatitudeDelta: Double
    let fixedLongitudeDelta: Double
    
    // This binding is to the main ContentView's mapCameraPosition.
    // We'll update it when the base is successfully set.
    @Binding var mainMapCameraPosition: MapCameraPosition

    // Local state for this sheet's own map
    @State private var sheetMapCameraPosition: MapCameraPosition
    @State private var prospectiveHomeBaseCoordinate: CLLocationCoordinate2D? // Coordinate at the reticle

    @StateObject private var regionChangeDebouncer = Debouncer(delay: 0.05) // Debouncer for map changes

    init(
        isPresented: Binding<Bool>,
        gameManager: GameManager,
        locationManager: LocationManager,
        fixedLatitudeDelta: Double,
        fixedLongitudeDelta: Double,
        initialMapCameraPosition: Binding<MapCameraPosition> // Renamed for clarity
    ) {
        self._isPresented = isPresented
        self.gameManager = gameManager
        self.locationManager = locationManager
        self.fixedLatitudeDelta = fixedLatitudeDelta
        self.fixedLongitudeDelta = fixedLongitudeDelta
        self._mainMapCameraPosition = initialMapCameraPosition

        // Initialize this sheet's map camera.
        // Start centered on the user's current location, or the main map's last known center.
        let initialCenterForSheet = locationManager.userLocation?.coordinate ?? initialMapCameraPosition.wrappedValue.region?.center ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let initialRegionForSheet = MKCoordinateRegion(
            center: initialCenterForSheet,
            span: MKCoordinateSpan(latitudeDelta: fixedLatitudeDelta, longitudeDelta: fixedLongitudeDelta)
        )
        // Use _sheetMapCameraPosition for @State initialization
        self._sheetMapCameraPosition = State(initialValue: .region(initialRegionForSheet))
        // Initialize prospective coordinate to the map's starting center
        self._prospectiveHomeBaseCoordinate = State(initialValue: initialCenterForSheet)
    }

    var body: some View {
        NavigationView { // Provides a title bar and standard sheet dismissal gestures
            ZStack {
                // Map for selecting the base location
                Map(position: $sheetMapCameraPosition, interactionModes: [.pan, .rotate]) {
                    UserAnnotation() // Show user's location for reference if desired
                }
                .onMapCameraChange(frequency: .continuous) { context in
                    // Debounce to avoid too many updates while panning
                    regionChangeDebouncer.debounce {
                        self.prospectiveHomeBaseCoordinate = context.camera.centerCoordinate
                        // print("Sheet map prospective coord: \(String(describing: self.prospectiveHomeBaseCoordinate))")
                    }
                }
                .overlay { // Central reticle
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red.opacity(0.8))
                        .allowsHitTesting(false) // Reticle should not intercept taps
                }
                .edgesIgnoringSafeArea(.bottom) // Allow map to go under controls a bit

                // Controls at the bottom
                VStack {
                    Spacer() // Pushes controls to the bottom
                    SetHomeBaseControls(
                        gameManager: gameManager,
                        locationManager: locationManager,
                        currentMapCenter: $prospectiveHomeBaseCoordinate,
                        cameraPosition: $sheetMapCameraPosition, // Controls modify this sheet's map
                        fixedLatitudeDelta: fixedLatitudeDelta,
                        fixedLongitudeDelta: fixedLongitudeDelta,
                        onSetAction: {
                            // When base is set, update the main map's camera to focus on the new home base
                            if let newHomeBaseCoord = gameManager.homeBase?.coordinate {
                                mainMapCameraPosition = .region(MKCoordinateRegion(
                                    center: newHomeBaseCoord,
                                    span: MKCoordinateSpan(latitudeDelta: fixedLatitudeDelta, longitudeDelta: fixedLongitudeDelta)
                                ))
                            }
                            isPresented = false // Dismiss this sheet
                        },
                        onCancelAction: {
                            isPresented = false // Dismiss this sheet
                        }
                    )
                }
            }
            .navigationTitle("Establish Your Sanctum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

// Optional: Preview for SetHomeBaseSheetView
struct SetHomeBaseSheetView_Previews: PreviewProvider {
    class MockGameManagerForSheet: GameManager {}
    class MockLocationManagerForSheet: LocationManager {
        override init() { super.init(); self.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) }
    }
    @State static var previewIsPresented = true // To show the sheet in preview
    @State static var previewMainMapCamera = MapCameraPosition.automatic

    static var previews: some View {
        SetHomeBaseSheetView(
            isPresented: $previewIsPresented,
            gameManager: MockGameManagerForSheet(),
            locationManager: MockLocationManagerForSheet(),
            fixedLatitudeDelta: 0.008,
            fixedLongitudeDelta: 0.008,
            initialMapCameraPosition: $previewMainMapCamera
        )
    }
}