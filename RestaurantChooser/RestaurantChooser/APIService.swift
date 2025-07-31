import Foundation
import CoreLocation

class APIService {
    static let shared = APIService()
    lazy var apiKey: String = self.loadAPIKey() // Correctly loads API key

    private let searchBaseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    private let textSearchBaseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    private let detailBaseUrl = "https://maps.googleapis.com/maps/api/place/details/json"

    private init() {}

    // THIS WAS MISSING - The definition for your API errors
    enum APIError: Error {
        case invalidURL
        case requestFailed(Error)
        case invalidResponse(String) // Include API status
        case decodingError(Error)
        case noData
    }

    // THIS WAS MISSING - Function to search nearby restaurants
    func searchNearbyRestaurants(latitude: Double, longitude: Double, radius: Int = 5000, completion: @escaping (Result<[Place], APIError>) -> Void) {
        var components = URLComponents(string: searchBaseUrl)
        components?.queryItems = [
            URLQueryItem(name: "location", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: apiKey), // Uses the loaded apiKey
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        performSearchRequest(url: url, completion: completion)
    }

    // THIS WAS MISSING - Function to search restaurants by name
    func searchRestaurantsByName(term: String, latitude: Double?, longitude: Double?, completion: @escaping (Result<[Place], APIError>) -> Void) {
        var components = URLComponents(string: textSearchBaseUrl)
        var queryItems = [
            URLQueryItem(name: "query", value: term),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: apiKey) // Uses the loaded apiKey
        ]

        if let lat = latitude, let lon = longitude {
             queryItems.append(URLQueryItem(name: "location", value: "\(lat),\(lon)"))
             queryItems.append(URLQueryItem(name: "radius", value: "20000"))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        performSearchRequest(url: url, completion: completion)
    }

    // THIS WAS MISSING (or will be needed soon) - Function to fetch Place Details
    func fetchPlaceDetails(placeId: String, completion: @escaping (Result<PlaceDetail, APIError>) -> Void) {
        var components = URLComponents(string: detailBaseUrl)
        let fields = "place_id,name,vicinity,geometry,rating,user_ratings_total,price_level,types,photos,formatted_address,formatted_phone_number,website,opening_hours"
        components?.queryItems = [
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "fields", value: fields),
            URLQueryItem(name: "key", value: apiKey) // Uses the loaded apiKey
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.requestFailed(error))) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse("HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? 0)"))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            do {
                let decoder = JSONDecoder()
                let detailResponse = try decoder.decode(GooglePlaceDetailResponse.self, from: data)
                if detailResponse.status == "OK", let placeDetail = detailResponse.result {
                    DispatchQueue.main.async {
                        completion(.success(placeDetail))
                    }
                } else {
                    DispatchQueue.main.async { completion(.failure(.invalidResponse("API Status: \(detailResponse.status)"))) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError(error))) }
            }
        }.resume()
    }

    // THIS WAS MISSING (or a version of it) - Helper for Nearby and Text Search requests
    // This can be private as it's only used by the public search methods above.
    private func performSearchRequest(url: URL, completion: @escaping (Result<[Place], APIError>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Ensure completion handlers are called on the main thread for UI updates
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.requestFailed(error))) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse("HTTP Error: \((response as? HTTPURLResponse)?.statusCode ?? 0)"))) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(GooglePlacesSearchResponse.self, from: data)
                if searchResponse.status == "OK" {
                    DispatchQueue.main.async {
                         completion(.success(searchResponse.results))
                    }
                } else if searchResponse.status == "ZERO_RESULTS" {
                     DispatchQueue.main.async {
                         completion(.success([]))
                     }
                }
                else {
                    DispatchQueue.main.async { completion(.failure(.invalidResponse("API Status: \(searchResponse.status)"))) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError(error))) }
            }
        }.resume()
    }

    // Your loadAPIKey function (this was present and correct)
    private func loadAPIKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("Couldn't find file 'Secrets.plist'. Make sure it's added to your app target and the name is correct.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "GoogleAPIKey") as? String else {
            fatalError("Couldn't find key 'GoogleAPIKey' in 'Secrets.plist' or it's not a string.")
        }
        if value.starts(with: "YOUR_") || value.isEmpty {
            fatalError("Please set your actual Google Places API Key in Secrets.plist for the 'GoogleAPIKey' entry.")
        }
        return value
    }
}
