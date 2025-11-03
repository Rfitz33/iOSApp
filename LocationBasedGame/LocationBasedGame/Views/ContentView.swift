import SwiftUI
import MapKit // Still needed for MapCameraPosition type

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var gameManager = GameManager.shared
    
    // State variables remain owned by ContentView
    @State private var mapCameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795), // Center of the USA
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50) // Zoomed way out
    ))
    @State private var cameraTrackingMode: CameraTrackingMode = .player // Uses top-level enum
    @State private var initialLocationSet = false
    @State private var initialSpawnDone = false

    @State private var showingMenuView: Bool = false
    @State private var showingHomeBaseViewAsFullScreen: Bool = false // For full screen presentation
    @State private var showingSetHomeBaseSheet: Bool = false
    
    var body: some View {
        // ContentView now just instantiates and displays MainScreenRouterView,
        // passing down necessary state and objects.
        MainScreenRouterView(
            locationManager: locationManager,
            gameManager: gameManager,
//            mapCameraPosition: $mapCameraPosition,
            cameraTrackingMode: $cameraTrackingMode,
            initialLocationSet: $initialLocationSet,
            initialSpawnDone: $initialSpawnDone,
            showingMenuView: $showingMenuView,
            showingHomeBaseViewAsFullScreen: $showingHomeBaseViewAsFullScreen,
            showingSetHomeBaseSheet: $showingSetHomeBaseSheet
        )
    }
}

// PreviewProvider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
