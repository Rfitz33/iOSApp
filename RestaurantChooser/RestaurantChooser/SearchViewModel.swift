//
//  SearchViewModel.swift
//  RestaurantChooser
//
//  Created by Reid on 5/6/25.
//


import Foundation
import Combine
import CoreLocation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var places: [Place] = [] // Changed from Restaurant to Place
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var userLocation: CLLocation? = nil

    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared

    // Store the actual API key for photo URLs (fetched securely)
    // This is a bit of a shortcut; ideally, the view model wouldn't hold the key directly.
    // A better approach would be for the APIService to have a method that constructs photo URLs.
    // Or, the view/row fetches it from a secure config when needed.
    // For simplicity in this example:
    let googleApiKey = APIService.shared.apiKey // Access the (hopefully secured) API key

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty && $0.count > 2 }
            .sink { [weak self] term in
                self?.performNameSearch(term: term)
            }
            .store(in: &cancellables)
    }

    func updateUserLocation(_ location: CLLocation?) {
        self.userLocation = location
    }

    func findNearbyRestaurants() {
        guard let location = userLocation else {
            errorMessage = "Could not get your location. Please enable location services."
            return
        }

        isLoading = true
        errorMessage = nil
        places = []

        apiService.searchNearbyRestaurants(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let fetchedPlaces):
                self.places = fetchedPlaces
                if fetchedPlaces.isEmpty {
                    self.errorMessage = "No nearby restaurants found."
                }
            case .failure(let error):
                self.handleAPIError(error)
            }
        }
    }

    func performNameSearch(term: String) {
        guard !term.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        places = []

        apiService.searchRestaurantsByName(term: term, latitude: userLocation?.coordinate.latitude, longitude: userLocation?.coordinate.longitude) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let fetchedPlaces):
                self.places = fetchedPlaces
                 if fetchedPlaces.isEmpty {
                    self.errorMessage = "No restaurants found for '\(term)'."
                }
            case .failure(let error):
                self.handleAPIError(error)
            }
        }
    }

    private func handleAPIError(_ error: APIService.APIError) {
        switch error {
        case .invalidResponse(let status):
            self.errorMessage = "API Error: \(status). Please try again later."
        case .requestFailed:
            self.errorMessage = "Network request failed. Check your connection."
        case .decodingError:
            self.errorMessage = "Error processing data. Please try again."
        default:
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        print("API Error: \(error)")
    }
}