//
//  FavoriteRestaurant.swift
//  RestaurantChooser
//
//  Created by Reid on 5/12/25.
//


import Foundation
import SwiftData
import CoreLocation

@Model
final class FavoriteRestaurant {
    @Attribute(.unique) var apiId: String // Google Place ID
    var name: String
    var latitude: Double
    var longitude: Double
    var rating: Double?
    var priceLevel: Int? // Stores Google's 0-4 integer
    var parsedCuisineTypes: [String]? // NEW: For specific cuisines like "Italian", "Mexican"
    var mealTypes: [String]?          // NEW: For "Breakfast", "Lunch", "Cafe"
    var userDefinedCuisineTags: [String]?
    var userDefinedMealTags: [String]?
    var address: String? // Vicinity or formatted_address
    var photoReference: String? // To reconstruct photo URL
    var addedDate: Date
    

    // Computed property for Google's price display ($, $$, etc.)
    var priceDisplay: String {
        guard let level = priceLevel else { return "" }
        if level == 0 { return "$" } // Or "Free" or empty
        return String(repeating: "$", count: level) // 1=$ 2=$$ 3=$$$ 4=$$$$
    }

    init(apiId: String, name: String, latitude: Double, longitude: Double, rating: Double? = nil, priceLevel: Int? = nil, parsedCuisineTypes: [String]? = nil, mealTypes: [String]? = nil, userDefinedCuisineTags: [String]? = nil, userDefinedMealTags: [String]? = nil, address: String? = nil, photoReference: String? = nil, addedDate: Date = Date()) {
        self.apiId = apiId
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.priceLevel = priceLevel
        self.parsedCuisineTypes = parsedCuisineTypes
        self.mealTypes = mealTypes
        self.userDefinedCuisineTags = userDefinedCuisineTags
        self.userDefinedMealTags = userDefinedMealTags
        self.address = address
        self.photoReference = photoReference
        self.addedDate = addedDate
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Helper to get photo URL (requires API key)
    func getPhotoURL(apiKey: String, maxWidth: Int = 400) -> URL? {
        guard let photoRef = photoReference else { return nil }
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoRef)&key=\(apiKey)")
    }
}
