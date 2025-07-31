//
//  SetHomeBaseControls.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//


import SwiftUI
import MapKit // For MapCameraPosition and CLLocationCoordinate2D
import CoreLocation // For CLLocation

// MARK: - SetHomeBaseControls
struct SetHomeBaseControls: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    
    @Binding var currentMapCenter: CLLocationCoordinate2D? // The coordinate at the map's reticle
    @Binding var cameraPosition: MapCameraPosition      // The camera of the map displaying these controls
    
    let fixedLatitudeDelta: Double
    let fixedLongitudeDelta: Double
    
    var onSetAction: (() -> Void)?    // Closure to call when base is set
    var onCancelAction: (() -> Void)? // Closure to call when cancelled

    var body: some View {
        VStack(spacing: 12) {
            Text("Pan map to choose your Sanctum's location. The red reticle marks the spot.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.regularMaterial) // Slightly more opaque than thinMaterial
                .cornerRadius(10)
                .shadow(radius: 2)

            HStack(spacing: 15) {
                Button {
                    onCancelAction?()
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.cancelAction) // Allows Esc key on iPad/Mac catalyst

                Button {
                    if let userCoord = locationManager.userLocation?.coordinate {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: userCoord,
                            span: MKCoordinateSpan(latitudeDelta: fixedLatitudeDelta, longitudeDelta: fixedLongitudeDelta)
                        ))
                        // currentMapCenter will update via onMapCameraChange in the parent sheet view
                    }
                } label: {
                    Label("Re-center", systemImage: "location.circle.fill")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    if let coord = currentMapCenter {
                        gameManager.setHomeBase(at: coord) // This will set gameManager.homeBase
                        onSetAction?() // Call the closure to dismiss the sheet
                    } else {
                        // This case should ideally not happen if currentMapCenter is always updated
                        print("Error: Cannot set home base, map center not determined.")
                    }
                } label: {
                    Label("Anchor Here", systemImage: "mappin.and.ellipse")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(currentMapCenter == nil) // Disable if no coordinate is determined yet
            }
        }
        .padding()
        .background(.ultraThinMaterial) // Background for the whole control panel
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Optional: Preview for SetHomeBaseControls
struct SetHomeBaseControls_Previews: PreviewProvider {
    // Mock GameManager and LocationManager for preview
    class MockGameManagerSetControls: GameManager {}
    class MockLocationManagerSetControls: LocationManager {
        override init() {
            super.init()
            self.userLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
    }

    @State static var previewMapCenter: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State static var previewCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    ))

    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all) // Mock background
            VStack {
                Spacer()
                SetHomeBaseControls(
                    gameManager: MockGameManagerSetControls(),
                    locationManager: MockLocationManagerSetControls(),
                    currentMapCenter: $previewMapCenter,
                    cameraPosition: $previewCameraPosition,
                    fixedLatitudeDelta: 0.008,
                    fixedLongitudeDelta: 0.008,
                    onSetAction: { print("Preview: Set Action Triggered") },
                    onCancelAction: { print("Preview: Cancel Action Triggered") }
                )
            }
        }
    }
}