//
//  ContentView 2.swift
//  RestaurantChooser
//
//  Created by Reid on 5/6/25.
//


import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var locationManager = LocationManager() // Assuming this is passed or env object

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("Find Nearby", systemImage: "location.fill") {
                        searchViewModel.findNearbyRestaurants()
                    }
                    .disabled(locationManager.userLocation == nil || searchViewModel.isLoading)
                    .padding(.leading)
                    Spacer()
                }
                .padding(.vertical, 8)

                if searchViewModel.isLoading {
                    ProgressView().padding()
                }

                if let errorMessage = searchViewModel.errorMessage, !searchViewModel.isLoading { // Show error only if not loading
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }

                // Changed to searchViewModel.places
                List(searchViewModel.places) { place in
                    NavigationLink(destination: RestaurantDetailView(placeId: place.placeId, initialPlaceData: place)) { // Pass placeId
                        RestaurantRow(place: place, apiKey: searchViewModel.googleApiKey) // Pass place and API key for photo
                    }
                }
                .listStyle(.plain)
                .searchable(text: $searchViewModel.searchText, prompt: "Search by name")
            }
            .navigationTitle("Find Restaurants")
            .onAppear {
                locationManager.requestLocationPermission()
            }
            .onReceive(locationManager.$userLocation) { location in
                 searchViewModel.updateUserLocation(location)
            }
            .onReceive(locationManager.$authorizationStatus) { status in
                 if status == .denied || status == .restricted {
                     searchViewModel.errorMessage = "Location permission denied. Please enable in Settings to find nearby places."
                 } else if status == .authorizedWhenInUse || status == .authorizedAlways {
                     if searchViewModel.errorMessage?.contains("permission") ?? false {
                         searchViewModel.errorMessage = nil
                     }
                     locationManager.startUpdatingLocation()
                 }
            }
        }
    }
}

// MARK: - Restaurant Row View (Helper - Google Version)
struct RestaurantRow: View {
    let place: Place
    let apiKey: String // Needed for Google Photo URL

    var body: some View {
        HStack {
            AsyncImage(url: place.getPhotoURL(apiKey: apiKey, maxWidth: 100)) { image in // Use helper
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "photo.artframe") // Different placeholder
                    .resizable().aspectRatio(contentMode: .fit).foregroundColor(.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(place.name).font(.headline)
                Text(place.vicinity ?? place.cuisineTypesDisplay).font(.subheadline).foregroundColor(.gray) // Show vicinity or cuisines
                HStack {
                    if let rating = place.rating {
                        Image(systemName: "star.fill").foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                    } else {
                        Text("No rating").font(.caption)
                    }
                    Text(place.priceDisplay).font(.caption) // Use priceDisplay helper
                }
                // Google Nearby Search doesn't directly give distance unless rankby=distance.
                // If you calculate it yourself using user's location and place.geometry:
                // Text("Approx. X miles").font(.caption).foregroundColor(.blue)
            }
            Spacer()
        }
    }
}

// #Preview {
//     ContentView()
//         .environmentObject(LocationManager()) // For preview
//         .modelContainer(for: FavoriteRestaurant.self, inMemory: true)
// }
