//
//  RestaurantModels.swift
//  RestaurantChooser
//
//  Created by Reid on 5/6/25.
//

import Foundation
import CoreLocation

// --- Google Places API Response Structures ---

// For Nearby Search & Text Search
struct GooglePlacesSearchResponse: Codable {
    let results: [Place]
    let status: String
    let nextPageToken: String? // For pagination

    enum CodingKeys: String, CodingKey {
        case results, status
        case nextPageToken = "next_page_token"
    }
}

// For Place Details
struct GooglePlaceDetailResponse: Codable {
    let result: PlaceDetail? // Result can be optional if place not found
    let status: String
}


struct Place: Codable, Identifiable, Equatable {
    var id: String { placeId } // Conform to Identifiable using place_id
    let placeId: String
    let name: String
    let vicinity: String? // Short address
    let geometry: Geometry?
    let rating: Double?
    let userRatingsTotal: Int?
    var priceLevel: Int? // 0-4 (Google's way)
    let types: [String]?
    let photos: [PhotoInfo]?
    let openingHours: OpeningHours?

    // These fields might only come from a Place Details request
    var formattedAddress: String?
    var formattedPhoneNumber: String?
    var website: String?
    // Add other detail fields as needed

    // Helper for cuisine display
    var cuisineTypesDisplay: String {
        types?
            .filter { !["point_of_interest", "establishment", "food", "store"].contains($0) } // Filter out generic types
            .map { $0.replacingOccurrences(of: "_", with: " ").capitalized }
            .prefix(3) // Show a few relevant ones
            .joined(separator: ", ") ?? "N/A"
    }

    // Helper for price display
    var priceDisplay: String {
        guard let level = priceLevel else { return "" }
        return String(repeating: "$", count: level + 1) // Google's 0-4 to $-$$$$$ (or just $ for 0)
                                                        // Or handle 0 as "Free" or empty
    }

    enum CodingKeys: String, CodingKey {
        case name, vicinity, geometry, rating, types, photos
        case placeId = "place_id"
        case userRatingsTotal = "user_ratings_total"
        case priceLevel = "price_level"
        case openingHours = "opening_hours"
        // Detail fields (ensure they are requested)
        case formattedAddress = "formatted_address"
        case formattedPhoneNumber = "formatted_phone_number"
        case website
    }
}

// PlaceDetail is used for the richer data from Place Details API
// It often has the same fields as Place, but we ensure they are populated
// You could merge Place and PlaceDetail if you always fetch details,
// or use Place for list items and PlaceDetail for the detail view.
// For simplicity here, we'll try to populate Place with details later.
typealias PlaceDetail = Place


struct Geometry: Codable, Equatable {
    let location: LatLng
}

struct LatLng: Codable, Equatable {
    let lat: Double
    let lng: Double
}

struct PhotoInfo: Codable, Equatable {
    let photoReference: String
    let height: Int
    let width: Int
    // To get actual image URL:
    // https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=PHOTO_REF&key=YOUR_API_KEY

    enum CodingKeys: String, CodingKey {
        case height, width
        case photoReference = "photo_reference"
    }
}

struct OpeningHours: Codable, Equatable {
    let openNow: Bool?

    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
    }
}

// --- Convenience Extension for Place ---
extension Place {
    var coordinate2D: CLLocationCoordinate2D? {
        guard let lat = geometry?.location.lat, let lng = geometry?.location.lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    func getPhotoURL(apiKey: String, maxWidth: Int = 400) -> URL? {
        guard let photoRef = photos?.first?.photoReference else { return nil }
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoRef)&key=\(apiKey)")
    }
}
