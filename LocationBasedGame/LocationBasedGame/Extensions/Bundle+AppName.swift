import Foundation

// MARK: - Bundle Extension for App Name
extension Bundle {
    var appName: String {
        // Attempt to get the display name first, which is often more user-friendly
        if let displayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, !displayName.isEmpty {
            return displayName
        }
        // Fallback to the bundle name (usually the Product Name)
        if let bundleName = object(forInfoDictionaryKey: "CFBundleName") as? String, !bundleName.isEmpty {
            return bundleName
        }
        // Ultimate fallback if neither is found or they are empty
        return "Your Awesome Game" // Provide a sensible default
    }
}
