//
//  MainTabView.swift
//  RestaurantChooser
//
//  Created by Reid on 5/12/25.
//


import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager = LocationManager() // Manage location centrally if needed across tabs

    var body: some View {
        TabView {
            ContentView() // Pass location manager if ContentView needs it directly
                // .environmentObject(locationManager) // Pass via environment if many children need it
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FavoritesView() // Pass location manager if FavoritesView needs it directly
                // .environmentObject(locationManager) // Pass via environment
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
         // Start location updates once when the TabView appears
         .onAppear {
              locationManager.requestLocationPermission()
              // Location updates will start based on authorization status handled within LocationManager
         }
         // Make locationManager available to all tabs via environment
         .environmentObject(locationManager)
    }
}

#Preview {
    MainTabView()
         // Provide a model container for previews involving SwiftData views
         .modelContainer(for: FavoriteRestaurant.self, inMemory: true)
}