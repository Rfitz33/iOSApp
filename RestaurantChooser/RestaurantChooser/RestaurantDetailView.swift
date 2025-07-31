import SwiftUI
import MapKit
import SwiftData

// Main View
struct RestaurantDetailView: View {
    let placeId: String
    // initialPlaceData should be @State if it can be modified or if its modification should trigger UI updates directly
    // If it's truly just an initial value, 'let' might be fine, but @State is safer if it's part of the view's dynamic state.
    // However, detailViewModel.place becomes the primary source of truth after fetching.
    @State var initialPlaceData: Place?

    @StateObject private var detailViewModel = RestaurantDetailViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var isFavorite: Bool = false

    @State private var mapCameraPosition: MapCameraPosition
    @State private var favoriteToEdit: FavoriteRestaurant? { // For the edit tags sheet
        didSet {
            if oldValue != nil && favoriteToEdit == nil {
                print("DetailView: favoriteToEdit changed from a value to nil. Sheet will dismiss.")
            }
            if oldValue == nil && favoriteToEdit != nil {
                print("DetailView: favoriteToEdit changed from nil to a value (\(favoriteToEdit!.name)). Sheet will show/re-show.")
            }
            if oldValue != nil && favoriteToEdit != nil && ObjectIdentifier(oldValue!) != ObjectIdentifier(favoriteToEdit!) {
                print("DetailView: favoriteToEdit changed from one favorite object to another. Sheet might re-render.")
            }
        }
    }

    private let apiKey = APIService.shared.apiKey // Assuming APIService.apiKey is accessible

    init(placeId: String, initialPlaceData: Place? = nil) {
        self.placeId = placeId
        self._initialPlaceData = State(initialValue: initialPlaceData)

        // Initialize mapCameraPosition
        if let coordinate = initialPlaceData?.coordinate2D {
            self._mapCameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )))
        } else {
            // Default region if no initial coordinate
            self._mapCameraPosition = State(initialValue: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default (e.g., SF)
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )))
        }
    }

    var body: some View {
        ScrollView {
            // Main conditional content rendering
            content
        }
        .navigationTitle(displayedPlace?.name ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Favorite Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let placeToSave = displayedPlace { toggleFavorite(place: placeToSave) }
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .accentColor)
                }
                .disabled(displayedPlace == nil)
            }

            // Edit Tags Button (if favorited)
            ToolbarItem(placement: .navigationBarTrailing) {
                if isFavorite {
                    Button {
                        fetchFavoriteForEditing()
                    } label: {
                        Label("Edit Tags", systemImage: "tag.circle") // Changed icon for distinction
                    }
                }
            }
        }
        .sheet(item: $favoriteToEdit) { favoriteItem in
             EditFavoriteTagsView(favorite: favoriteItem)
        }
        .onAppear {
            detailViewModel.fetchDetails(for: placeId)
            checkIfFavorite()
        }
        .onChange(of: detailViewModel.place) { // Using new syntax
            checkIfFavorite() // Re-check favorite status when details load
            if let newCoordinate = detailViewModel.place?.coordinate2D {
                withAnimation {
                    mapCameraPosition = .region(MKCoordinateRegion(
                        center: newCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
        }
    }

    // Computed property to simplify access to the place data
    private var displayedPlace: Place? {
        detailViewModel.place ?? initialPlaceData
    }

    // Extracted content view builder
    @ViewBuilder
    private var content: some View {
        if detailViewModel.isLoading && detailViewModel.place == nil {
            ProgressView("Loading details...").padding()
        } else if let place = displayedPlace {
            VStack(alignment: .leading, spacing: 15) {
                RestaurantPhotoView(place: place, apiKey: apiKey)
                RestaurantMapView(place: place, mapCameraPosition: $mapCameraPosition) // Pass binding
                RestaurantInfoSection(place: place)
                Divider().padding(.horizontal)
                RestaurantContactLocationSection(place: place)
                RestaurantAttributionView() // Added for Google attribution
            }
            .padding(.bottom) // Add some padding at the bottom of the VStack
        } else if let errorMessage = detailViewModel.errorMessage {
            Text("Error loading details: \(errorMessage)")
                .foregroundColor(.red)
                .padding()
        } else {
            // Fallback if nothing else matches (e.g., initial state before loading starts if initialPlaceData is nil)
            ProgressView().padding()
        }
    }
    
    // --- Data Management Methods ---
    private func fetchFavoriteForEditing() {
        let currentPlaceId = self.placeId
        let fetchDescriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { $0.apiId == currentPlaceId }
        )
        do {
            if let fav = try modelContext.fetch(fetchDescriptor).first {
                self.favoriteToEdit = fav
            } else {
                print("DetailView: Could not find favorite \(currentPlaceId) in context to edit tags for.")
            }
        } catch {
            print("DetailView: Error fetching favorite for editing tags: \(error)")
        }
    }

    private func checkIfFavorite() {
        let currentPlaceId = self.placeId
        let fetchDescriptor = FetchDescriptor<FavoriteRestaurant>(
            predicate: #Predicate { favoriteRestaurant in
                favoriteRestaurant.apiId == currentPlaceId
            }
        )
        do {
            let favorites = try modelContext.fetch(fetchDescriptor)
            isFavorite = !favorites.isEmpty
        } catch {
            print("DetailView: Failed to fetch favorite status: \(error)")
            isFavorite = false
        }
    }

    private func toggleFavorite(place: Place) {
        let idToToggle = self.placeId // Use the ID of the current detail view's place for consistency

        if isFavorite { // Trying to unfavorite
            let fetchDescriptor = FetchDescriptor<FavoriteRestaurant>(
                predicate: #Predicate { $0.apiId == idToToggle }
            )
            do {
                if let favoriteToRemove = try modelContext.fetch(fetchDescriptor).first {
                    modelContext.delete(favoriteToRemove)
                    isFavorite = false
                    print("DetailView: Removed \(place.name) (ID: \(idToToggle)) from favorites")
                } else {
                    print("DetailView: Could not find favorite with ID \(idToToggle) to remove (was trying to unfavorite).")
                    isFavorite = false // Correct the state if it was out of sync
                }
            } catch {
                print("DetailView: Failed to remove favorite: \(error)")
            }
        } else { // Trying to favorite
            let extractedCuisines = TypeProcessor.extractCuisineTypes(from: place.types)
            let extractedMealTypes = TypeProcessor.extractMealTypes(from: place.types, name: place.name)

            print("DetailView: Saving Favorite: \(place.name)")
            print("DetailView: Google Original Types: \(place.types ?? [])")
            print("DetailView: Extracted Cuisines: \(extractedCuisines)")
            print("DetailView: Extracted Meal Types: \(extractedMealTypes)")

            let newFavorite = FavoriteRestaurant(
                apiId: place.placeId, // Use place.placeId as this is a new object from API data
                name: place.name,
                latitude: place.geometry?.location.lat ?? 0.0,
                longitude: place.geometry?.location.lng ?? 0.0,
                rating: place.rating,
                priceLevel: place.priceLevel,
                parsedCuisineTypes: extractedCuisines,
                mealTypes: extractedMealTypes,
                userDefinedCuisineTags: extractedCuisines, // Default user tags to parsed ones
                userDefinedMealTags: extractedMealTypes,   // User can edit these later via EditFavoriteTagsView
                address: place.formattedAddress ?? place.vicinity,
                photoReference: place.photos?.first?.photoReference,
                addedDate: Date()
            )
            modelContext.insert(newFavorite)
            isFavorite = true // Update UI state
            // Now, set this newly created favorite for tag editing
            self.favoriteToEdit = newFavorite // This will trigger the sheet
            print("DetailView: Added \(place.name) (ID: \(place.placeId)) to favorites. Presenting tag editor.")
        }
    }
}

// ViewModel (RestaurantDetailViewModel - assumed to be the same as before)
@MainActor
class RestaurantDetailViewModel: ObservableObject {
    @Published var place: Place? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    private let apiService = APIService.shared

    func fetchDetails(for placeId: String) {
        // Avoid refetching if same ID and already loaded OR if already loading
        guard (place?.placeId != placeId || place == nil) && !isLoading else { return }

        isLoading = true
        errorMessage = nil
        // Consider setting self.place = nil here if you want to clear old data while new loads
        // However, this might cause a flicker if initialPlaceData was being shown.

        apiService.fetchPlaceDetails(placeId: placeId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let detailedPlace):
                self.place = detailedPlace
            case .failure(let error):
                // Only set error message if we didn't manage to load any place data
                if self.place == nil {
                    self.errorMessage = "Failed to load details: \(error.localizedDescription)"
                }
                print("Detail Fetch Error: \(error)")
            }
        }
    }
}


// --- Helper Subviews ---

struct RestaurantPhotoView: View {
    let place: Place
    let apiKey: String

    var body: some View {
        Group {
            if let photoUrl = place.getPhotoURL(apiKey: apiKey, maxWidth: 800) {
                AsyncImage(url: photoUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 250) // Give it a defined height while loading
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit)
                             .frame(maxWidth: .infinity) // Allow it to take width
                             .frame(maxHeight: 300)      // But constrain height
                    case .failure(let error):
                        Image(systemName: "photo.artframe")
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(height: 200).frame(maxWidth: .infinity)
                            .foregroundColor(.gray).background(Color.gray.opacity(0.1))
                        Text("Image failed to load: \(error.localizedDescription)")
                            .font(.caption).foregroundColor(.red)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "photo.artframe")
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(height: 200).frame(maxWidth: .infinity)
                    .foregroundColor(.gray).background(Color.gray.opacity(0.1))
            }
        }
    }
}

struct RestaurantMapView: View {
    let place: Place
    @Binding var mapCameraPosition: MapCameraPosition

    var body: some View {
        Group { // Using Group to allow conditional content at the top level if needed later
            if let coordinate = place.coordinate2D {
                Map(position: $mapCameraPosition) {
                    Marker(place.name, coordinate: coordinate)
                        .tint(.blue)
                }
                .frame(height: 200)
            } else {
                Rectangle().fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(Text("Map data not available"))
            }
        }
    }
}

struct RestaurantInfoSection: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(place.name)
                .font(.largeTitle).fontWeight(.bold)

            Text(place.cuisineTypesDisplay) // Uses the helper from Place model
                .font(.headline).foregroundColor(.secondary)

            HStack {
                 if let rating = place.rating {
                      RatingView(rating: rating) // Assumes RatingView is defined
                      Text("(\(place.userRatingsTotal ?? 0) ratings)")
                          .font(.subheadline).foregroundColor(.secondary)
                 }
                Text(place.priceDisplay).font(.headline).padding(.leading) // Uses helper from Place model
            }
            if let isOpen = place.openingHours?.openNow {
                Text(isOpen ? "Open Now" : "Closed Now")
                    .font(.subheadline)
                    .foregroundColor(isOpen ? .green : .red)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal)
    }
}

struct RestaurantContactLocationSection: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Contact & Location").font(.title2).fontWeight(.semibold)
            if let phone = place.formattedPhoneNumber {
                HStack {
                    Image(systemName: "phone.fill")
                    Link(phone, destination: URL(string: "tel:\(phone.filter("0123456789+".contains))")!)
                }
            }
            if let address = place.formattedAddress ?? place.vicinity {
                HStack(alignment: .top) {
                    Image(systemName: "mappin.and.ellipse").padding(.top, 4)
                    Text(address)
                }
            }
            if let website = place.website, let url = URL(string: website) {
                HStack {
                    Image(systemName: "safari.fill")
                    Link(website, destination: url)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct RestaurantAttributionView: View {
    var body: some View {
        HStack {
            Spacer()
            // You should ideally use Google's official assets if available,
            // or ensure text meets their branding guidelines.
            Image("powered_by_google_on_white") // Assuming you have this asset
                .resizable()
                .scaledToFit()
                .frame(height: 18) // Adjust size as needed
            // Fallback text if image isn't available or for simplicity:
            // Text("Powered by Google")
            //     .font(.caption)
            //     .foregroundColor(.gray)
            Spacer()
        }
        .padding(.vertical, 10)
    }
}


// Ensure these helper structs (RestaurantAnnotation, RatingView) are also defined
// (They were provided in earlier responses)

// Simple annotation struct for the map (only needed if you use multiple/custom map annotations later)
// struct RestaurantAnnotation: Identifiable {
//     let id = UUID()
//     let coordinate: CLLocationCoordinate2D
// }

// Simple star rating view
struct RatingView: View {
    let rating: Double
    private let maxRating = 5

    var body: some View {
        HStack(spacing: 1) { // Reduced spacing for tighter stars
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: imageName(for: index))
                    .foregroundColor(.yellow)
                    .font(.callout) // Adjust star size
            }
        }
    }

    private func imageName(for index: Int) -> String {
        let currentStarValue = Double(index)
        if rating >= currentStarValue + 1.0 {
            return "star.fill"
        } else if rating >= currentStarValue + 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
