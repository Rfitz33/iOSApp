//
//  TypeProcessor.swift
//  RestaurantChooser
//
//  Created by Reid on 5/22/25.
//


import Foundation

struct TypeProcessor {

    // --- Predefined Cuisine Types ---
    // This list can be expanded. Keys are what Google might provide (or parts of it),
    // values are the user-friendly display names.
    // We'll aim to match keywords.
    static let knownCuisineKeywords: [String: String] = [
        "italian": "Italian", "pizza": "Pizza", // Often Google says "italian_restaurant"
        "mexican": "Mexican", "taco": "Mexican",
        "chinese": "Chinese",
        "japanese": "Japanese", "sushi": "Sushi", "ramen": "Ramen",
        "indian": "Indian",
        "thai": "Thai",
        "vietnamese": "Vietnamese",
        "korean": "Korean",
        "french": "French",
        "greek": "Greek",
        "spanish": "Spanish",
        "mediterranean": "Mediterranean",
        "american": "American", "burger": "Burgers", "steak": "Steakhouse",
        "bbq": "BBQ", "barbecue": "BBQ",
        "seafood": "Seafood",
        "vegetarian": "Vegetarian",
        "vegan": "Vegan",
        "gluten_free": "Gluten-Free", // Less common as a primary type from Google
        "latin_american": "Latin American",
        "caribbean": "Caribbean",
        "middle_eastern": "Middle Eastern",
        "african": "African",
        "bakery": "Bakery", // Could be cuisine or venue
        "dessert": "Desserts",
        // Add more as needed
    ]

    // --- Predefined Meal Types ---
    // Keywords to look for. Google is less likely to provide these directly in 'types'
    // but they might appear in the name or other text if we had it.
    // For now, we'll make "Cafe" a meal type as per your request.
    static let knownMealTypeKeywords: [String: String] = [
        "breakfast": "Breakfast",
        "brunch": "Brunch",
        "lunch": "Lunch",
        "dinner": "Dinner",
        "cafe": "Cafe", // As requested, cafe as a meal/occasion type
        "coffee": "Coffee", // Often associated with Cafe
        "tea": "Tea"
    ]
    
    // General establishment types to filter out from cuisine/meal consideration
    static let generalEstablishmentTypes: Set<String> = [
        "restaurant", "food", "point_of_interest", "establishment", "store", "bar", "meal_takeaway", "meal_delivery"
    ]

    static func extractCuisineTypes(from googleTypes: [String]?) -> [String] {
        guard let googleTypes = googleTypes else { return [] }
        var cuisines: Set<String> = []
        print("TypeProcessor - extractCuisineTypes - Input: \(googleTypes)") // DEBUG

        for type in googleTypes {
            let lowercasedType = type.lowercased().replacingOccurrences(of: "_restaurant", with: "") // "italian_restaurant" -> "italian"
                                               .replacingOccurrences(of: "_food", with: "")
            print("TypeProcessor - processing type: \(type) -> cleaned: \(lowercasedType)") // DEBUG
            
            if generalEstablishmentTypes.contains(lowercasedType) { // e.g. "restaurant", "food"
                print("TypeProcessor - '\(lowercasedType)' is a general type, skipping for cuisine.") // DEBUG
                continue
            }

            // Direct match or keyword match
            if let friendlyName = knownCuisineKeywords[lowercasedType] {
                cuisines.insert(friendlyName)
                print("TypeProcessor - Matched '\(lowercasedType)' to cuisine: \(friendlyName)") // DEBUG
            } else {
                // Check for partial keywords within the type string
                for (keyword, friendlyName) in knownCuisineKeywords {
                    if lowercasedType.contains(keyword) {
                        cuisines.insert(friendlyName)
                        break // Found a match for this type, move to next googleType
                    }
                }
            }
        }
        // If no specific cuisines found, but it's a 'restaurant', maybe add a generic 'Restaurant' tag or leave empty
        // For now, we only add specific known cuisines.
        print("TypeProcessor - extractCuisineTypes - Output: \(Array(cuisines).sorted())") // DEBUG
        return Array(cuisines).sorted()
    }

    static func extractMealTypes(from googleTypes: [String]?, name: String? = nil) -> [String] {
        var mealTypes: Set<String> = []
        
        if let types = googleTypes {
            for type in types {
                let lowercasedType = type.lowercased()
                if let friendlyName = knownMealTypeKeywords[lowercasedType] {
                    mealTypes.insert(friendlyName)
                } else {
                    for (keyword, friendlyName) in knownMealTypeKeywords {
                        if lowercasedType.contains(keyword) {
                            mealTypes.insert(friendlyName)
                            break
                        }
                    }
                }
            }
        }
        
        // Optionally, you could also check the restaurant's name for keywords
        // if let placeName = name?.lowercased() {
        //     for (keyword, friendlyName) in knownMealTypeKeywords {
        //         if placeName.contains(keyword) && !mealTypes.contains(friendlyName) {
        //             mealTypes.insert(friendlyName)
        //         }
        //     }
        // }
        
        return Array(mealTypes).sorted()
    }
}
