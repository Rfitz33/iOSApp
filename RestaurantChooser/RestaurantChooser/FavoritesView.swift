import SwiftUI
import SwiftData
import CoreLocation

struct FavoritesView: View {
    // Query to get all favorite restaurants, sorted by added date
    @Query(sort: \FavoriteRestaurant.addedDate, order: .reverse) private var favorites: [FavoriteRestaurant]

    // Environment access
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager() // Need location for distance filter

    // --- Filter states ---
    @State private var selectedDistance: Double = 5.0 // Max distance in miles
    @State private var filterByDistance: Bool = false

    @State private var selectedPriceLevels: Set<Int> = [] // Google's price level (0-4)
    @State private var filterByPrice: Bool = false

    // OLD Cuisine Filter States (To be REPLACED or REMOVED)
    // @State private var selectedCuisine: String = ""
    // @State private var filterByCuisine: Bool = false

    // NEW Parsed Cuisine Filter States
    @State private var selectedParsedCuisine: String = "" // For specific cuisines like "Italian"
    @State private var filterByParsedCuisine: Bool = false

    // NEW Meal Type Filter States
    @State private var selectedMealType: String = ""     // For "Breakfast", "Lunch", "Cafe"
    @State private var filterByMealType: Bool = false

    @State private var excludedFavoriteIDs: Set<String> = [] // Store apiId of excluded ones

    // State for showing the chosen restaurant
    @State private var chosenRestaurant: FavoriteRestaurant? = nil
    @State private var showNoMatchesAlert = false

    // Get API key for photo URLs (needs secure handling if you display photos in the list)
    // private let apiKey = APIService.shared.apiKey

    // Computed property for available PARSED cuisines from favorites
    private var availableParsedCuisines: [String] {
        // This will collect all unique 'parsedCuisineTypes' from your FavoriteRestaurant objects
        Array(Set(favorites.flatMap { $0.parsedCuisineTypes ?? [] })).filter { !$0.isEmpty }.sorted()
    }
    
    // In FavoritesView.swift
    private var allAvailableCuisineOptions: [String] {
        let googleCuisines = Set(favorites.flatMap { $0.parsedCuisineTypes ?? [] })
        let userCuisines = Set(favorites.flatMap { $0.userDefinedCuisineTags ?? [] })
        return Array(googleCuisines.union(userCuisines)).filter { !$0.isEmpty }.sorted()
    }

    private var allAvailableMealTypeOptions: [String] {
        let googleMeals = Set(favorites.flatMap { $0.mealTypes ?? [] })
        let userMeals = Set(favorites.flatMap { $0.userDefinedMealTags ?? [] })
        return Array(googleMeals.union(userMeals)).filter { !$0.isEmpty }.sorted()
    }

    // Computed property for available MEAL TYPES from favorites
    private var availableMealTypes: [String] {
        // This will collect all unique 'mealTypes' from your FavoriteRestaurant objects
        Array(Set(favorites.flatMap { $0.mealTypes ?? [] })).filter { !$0.isEmpty }.sorted()
    }

    private var availablePriceLevelsSorted: [Int] {
         Array(Set(favorites.compactMap { $0.priceLevel })).sorted()
    }
    private func displayPriceForLevel(_ level: Int) -> String {
        if level == 0 { return "$" }
        return String(repeating: "$", count: level)
    }


    var body: some View {
        NavigationView {
            VStack {
                // --- Filter Controls Section ---
                DisclosureGroup("Filters") {
                    VStack(alignment: .leading, spacing: 10) { // Added spacing
                        // Distance Filter
                        Toggle("Filter by Distance", isOn: $filterByDistance.animation())
                        if filterByDistance {
                            HStack {
                                Text("Max Distance: \(selectedDistance, specifier: "%.1f") miles")
                                Slider(value: $selectedDistance, in: 0.5...25.0, step: 0.5)
                            }
                            if (locationManager.userLocation == nil && filterByDistance) ||
                               (filterByDistance && locationManager.authorizationStatus != .authorizedWhenInUse && locationManager.authorizationStatus != .authorizedAlways) {
                                 Text("Enable location services to filter by distance.")
                                     .font(.caption).foregroundColor(.orange)
                             }
                        }
                        Divider()

                        // Price Filter
                        Toggle("Filter by Price", isOn: $filterByPrice.animation())
                        if filterByPrice {
                            if !availablePriceLevelsSorted.isEmpty {
                                 HStack(spacing: 5) { // Use a ScrollView if many price levels
                                      Text("Price:")
                                      ForEach(availablePriceLevelsSorted, id: \.self) { level in
                                           Button { togglePriceSelection(level) } label: {
                                                Text(displayPriceForLevel(level))
                                                     .padding(.horizontal, 8).padding(.vertical, 4)
                                                     .background(selectedPriceLevels.contains(level) ? Color.blue : Color.gray.opacity(0.2))
                                                     .foregroundColor(selectedPriceLevels.contains(level) ? .white : .primary)
                                                     .clipShape(Capsule())
                                           }
                                      }
                                 }
                             } else {
                                 Text("No price levels found in current favorites.").font(.caption)
                             }
                         }
                         Divider()

                        // --- NEW Parsed Cuisine Filter ---
                        Toggle("Filter by Cuisine", isOn: $filterByParsedCuisine.animation())
                        if filterByParsedCuisine {
                            if !allAvailableCuisineOptions.isEmpty { // Use the new combined list
                                Picker("Cuisine", selection: $selectedParsedCuisine) {
                                    Text("Any Cuisine").tag("")
                                    ForEach(allAvailableCuisineOptions, id: \.self) { cuisine in // Iterate over combined list
                                        Text(cuisine).tag(cuisine)
                                    }
                                }.pickerStyle(.menu)
                            } else {
                                Text("No specific cuisines found in favorites to filter by.").font(.caption)
                            }
                        }
                        Divider()

                        // --- NEW Meal Type Filter ---
                        Toggle("Filter by Meal/Occasion", isOn: $filterByMealType.animation())
                        if filterByMealType {
                            if !allAvailableMealTypeOptions.isEmpty { // Use the new combined list
                                Picker("Meal/Occasion", selection: $selectedMealType) {
                                    Text("Any Meal/Occasion").tag("")
                                    ForEach(allAvailableMealTypeOptions, id: \.self) { mealType in // Iterate over combined list
                                        Text(mealType).tag(mealType)
                                    }
                                }.pickerStyle(.menu)
                            } else {
                                Text("No meal/occasion types found in favorites to filter by.").font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 5) // Add some padding inside the DisclosureGroup
                }
                .padding(.horizontal)


                // --- List of Favorites Section ---
                if favorites.isEmpty {
                     Spacer()
                     Text("No favorites yet!").font(.title2).foregroundColor(.gray)
                     Text("Search for restaurants and tap the ❤️ on their detail page to add them.")
                         .font(.callout).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                     Spacer()
                } else {
                    List {
                        // Iterate over the dynamically filtered list
                        ForEach(getFilteredFavorites()) { favorite in
                            HStack {
                                 // Optional: Display small photo using favorite.getPhotoURL(apiKey: apiKey)
                                 // AsyncImage(...)

                                 VStack(alignment: .leading) {
                                      Text(favorite.name).font(.headline)
                                      // Display parsed cuisines
                                      if let cuisines = favorite.parsedCuisineTypes, !cuisines.isEmpty {
                                          Text("Cuisines: \(cuisines.prefix(2).joined(separator: ", "))")
                                               .font(.caption).foregroundColor(.gray)
                                      }
                                      // Display meal types
                                      if let meals = favorite.mealTypes, !meals.isEmpty {
                                          Text("Meals: \(meals.prefix(2).joined(separator: ", "))")
                                               .font(.caption).foregroundColor(.orange) // Different color for distinction
                                      }
                                      Text("Price: \(favorite.priceDisplay)").font(.caption)
                                 }
                                 Spacer()
                                 Image(systemName: excludedFavoriteIDs.contains(favorite.apiId) ? "checkmark.circle.fill" : "circle")
                                     .foregroundColor(excludedFavoriteIDs.contains(favorite.apiId) ? .red : .gray)
                                     .onTapGesture { toggleExclusion(favorite.apiId) }
                            }
                            .opacity(excludedFavoriteIDs.contains(favorite.apiId) ? 0.5 : 1.0)
                        }
                        .onDelete(perform: deleteFavorite)
                    }
                    .listStyle(.plain)
                    // Display message if filters result in no matches but favorites list is not empty
                    if !favorites.isEmpty && getFilteredFavorites().isEmpty {
                        Spacer()
                        Text("No favorites match your current filters.")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }

                // --- "Help Me Choose!" Button ---
                Button {
                    chooseRandomRestaurant()
                } label: {
                    Label("Help Me Choose!", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                // Disable if the list (after all filters and exclusions) would be empty
                .disabled(getFilteredFavorites().filter { !excludedFavoriteIDs.contains($0.apiId) }.isEmpty && !favorites.isEmpty)


            } // End of main VStack
            .navigationTitle("My Favorites")
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { EditButton() } }
            .sheet(item: $chosenRestaurant) { restaurant in /* ... sheet content ... */ }
            .alert("No Matches for Random Pick", isPresented: $showNoMatchesAlert) { /* ... alert content ... */ }
            .onAppear {
                locationManager.requestLocationPermission()
                // Location updates start based on authorization status
            }
            .onReceive(locationManager.$authorizationStatus) { status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    locationManager.startUpdatingLocation()
                }
            }
        } // End of NavigationView
    } // End of body

    // --- Methods ---
    private func togglePriceSelection(_ level: Int) { /* ... same ... */ }
    private func toggleExclusion(_ id: String) { /* ... same ... */ }
    private func deleteFavorite(offsets: IndexSet) {
        let itemsToDelete = offsets.map { getFilteredFavorites()[$0] } // Assumes getFilteredFavorites is stable for indices
        withAnimation {
            itemsToDelete.forEach(modelContext.delete)
        }
    }

    // getFilteredFavorites() - use the complete version from the previous message
    private func getFilteredFavorites() -> [FavoriteRestaurant] {
        // ... (Full implementation as provided before) ...
        guard !favorites.isEmpty else { return [] }
        let currentCLLocation = (filterByDistance && locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways)
                                ? locationManager.userLocation
                                : nil
        let filteredList = favorites.filter { favorite in
            if filterByDistance {
                guard let userLocation = currentCLLocation else { return false }
                let restaurantLocation = CLLocation(latitude: favorite.latitude, longitude: favorite.longitude)
                let distanceInMeters = userLocation.distance(from: restaurantLocation)
                let distanceInMiles = distanceInMeters / 1609.34
                if distanceInMiles > selectedDistance { return false }
            }
            if filterByPrice && !selectedPriceLevels.isEmpty {
                guard let favoritePrice = favorite.priceLevel, selectedPriceLevels.contains(favoritePrice) else { return false }
            }
            // ---- UPDATED CUISINE FILTER CHECK ----
            if filterByParsedCuisine && !selectedParsedCuisine.isEmpty {
                        let hasGoogleCuisine = favorite.parsedCuisineTypes?.contains(selectedParsedCuisine) ?? false
                        let hasUserCuisine = favorite.userDefinedCuisineTags?.contains(selectedParsedCuisine) ?? false
                        if !hasGoogleCuisine && !hasUserCuisine {
                            return false // Exclude if not in either
                        }
            }
            // ---- UPDATED MEAL TYPE FILTER CHECK ----
            if filterByMealType && !selectedMealType.isEmpty {
                        let hasGoogleMeal = favorite.mealTypes?.contains(selectedMealType) ?? false
                        let hasUserMeal = favorite.userDefinedMealTags?.contains(selectedMealType) ?? false
                        if !hasGoogleMeal && !hasUserMeal {
                            return false // Exclude if not in either
                        }
                    }
            return true
        }
        return filteredList
    }

    private func chooseRandomRestaurant() { /* ... same, uses getFilteredFavorites() and then filters by excludedFavoriteIDs ... */ }

} // End of FavoritesView
