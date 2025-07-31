//
//  DeviceLocationDisabledView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//


import SwiftUI

// MARK: - Permission Views

struct DeviceLocationDisabledView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Location Services Disabled")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Please enable Location Services in your iPhone's Settings (Settings > Privacy & Security > Location Services) to use this app.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct PermissionRequestView: View {
    // This view needs the LocationManager to request permission
    @ObservedObject var locationManager: LocationManager // Assume LocationManager is passed or available

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Welcome to \(Bundle.main.appName)!") // Assumes Bundle+AppName extension exists
                .font(.title2)
                .fontWeight(.semibold)
            Text("This game uses your location to place you on the map and help you find in-game resources in the real world.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Grant Location Permission") {
                locationManager.requestLocationPermission()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Location Access Denied")
                .font(.title2)
                .fontWeight(.semibold)
            Text("To play the game, \(Bundle.main.appName) needs access to your location. Please enable it in Settings for this app.") // Assumes Bundle+AppName extension
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open App Settings") {
                // This URL directly opens your app's settings page
                if let bundleId = Bundle.main.bundleIdentifier, let url = URL(string: "\(UIApplication.openSettingsURLString)&path=\(bundleId)") {
                     UIApplication.shared.open(url)
                } else if let url = URL(string: UIApplication.openSettingsURLString) {
                    // Fallback to general settings if specific app settings URL fails
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// Previews for PermissionViews (optional, but good for design)
struct PermissionViews_Previews: PreviewProvider {
    // Mock LocationManager for previews
    class MockLocationManager: LocationManager {
        // Override properties or methods as needed for different preview states
    }

    static var previews: some View {
        let mockManager = MockLocationManager() // Create an instance
        // You might need to set properties on mockManager for different previews
        // e.g., mockManager.authorizationStatus = .denied for PermissionDeniedView

        Group {
            DeviceLocationDisabledView()
                .previewDisplayName("Device Location Disabled")

            // PermissionRequestView needs a LocationManager instance.
            // If LocationManager() initializer is simple and doesn't start heavy processes,
            // you can use it directly. Otherwise, use a mock.
            PermissionRequestView(locationManager: mockManager)
                .previewDisplayName("Permission Request")
            
            PermissionDeniedView()
                .previewDisplayName("Permission Denied")
        }
    }
}