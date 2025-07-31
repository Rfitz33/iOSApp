import SwiftUI
// Make sure SwiftData is imported if you need to interact with modelContext directly here,
// though with @Bindable, it might not be strictly necessary *in this view* if the parent handles the @Model.
// import SwiftData

struct EditFavoriteTagsView: View {
    @Environment(\.dismiss) var dismiss
    // Use @Bindable to allow this view to directly modify the properties
    // of the FavoriteRestaurant object passed in.
    // SwiftData will handle saving these changes.
    @Bindable var favorite: FavoriteRestaurant

    // Predefined lists for suggestions
    // These could also be passed in or fetched from a shared source
    let allKnownCuisines: [String]
    let allKnownMealTypes: [String]

    // Local state for managing the selections within this sheet
    // Initialized from the favorite object's current state
    @State private var selectedCuisineTags: Set<String>
    @State private var selectedMealTags: Set<String>
    @State private var newCustomCuisineTag: String = ""
    @State private var newCustomMealTag: String = ""

    // Initializer
    // This init is crucial. It sets up the local @State variables based on the
    // 'favorite' object that is passed in.
    init(favorite: FavoriteRestaurant) {
        self.favorite = favorite // Assign the passed-in favorite to our @Bindable property
        
        // Create sorted and unique lists for pickers
        // 1. Get values, 2. Convert to Set to make unique, 3. Convert back to Array, 4. Sort
        self.allKnownCuisines = Array(Set(TypeProcessor.knownCuisineKeywords.values)).sorted()
        self.allKnownMealTypes = Array(Set(TypeProcessor.knownMealTypeKeywords.values)).sorted()

        // Initialize local @State based on the favorite's current tags
        // If userDefined tags exist, use them. Otherwise, fall back to parsed (Google) types as a starting point.
        // If both are nil, start with an empty set.
        let initialCuisines = favorite.userDefinedCuisineTags ?? favorite.parsedCuisineTypes ?? []
        self._selectedCuisineTags = State(initialValue: Set(initialCuisines))

        let initialMeals = favorite.userDefinedMealTags ?? favorite.mealTypes ?? []
        self._selectedMealTags = State(initialValue: Set(initialMeals))
    }

    var body: some View { // Ensure this is 'var body: some View'
        NavigationView { // Good for sheets to have their own NavigationView for title/buttons
            Form {
                Section("Cuisine Tags") {
                    // Multi-selector for predefined cuisines
                    List { // Using List for better layout of Toggles
                        ForEach(allKnownCuisines, id: \.self) { cuisine in
                            Toggle(cuisine, isOn: Binding(
                                get: { selectedCuisineTags.contains(cuisine) },
                                set: { isOn in
                                    if isOn { selectedCuisineTags.insert(cuisine) }
                                    else { selectedCuisineTags.remove(cuisine) }
                                }
                            ))
                        }
                    } // End of List for predefined cuisines

                    // Allow adding custom cuisine tags
                    HStack {
                        TextField("Add custom cuisine...", text: $newCustomCuisineTag)
                        Button("Add") {
                            let trimmedTag = newCustomCuisineTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedTag.isEmpty {
                                selectedCuisineTags.insert(trimmedTag)
                                newCustomCuisineTag = "" // Clear input field
                            }
                        }
                        .disabled(newCustomCuisineTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }

                    // Display currently selected/custom cuisine tags
                    if !selectedCuisineTags.isEmpty {
                        Text("Selected: \(selectedCuisineTags.sorted().joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                } // End of Cuisine Tags Section

                Section("Meal/Occasion Tags") {
                    List { // Using List for better layout of Toggles
                        ForEach(allKnownMealTypes, id: \.self) { mealType in
                            Toggle(mealType, isOn: Binding(
                                get: { selectedMealTags.contains(mealType) },
                                set: { isOn in
                                    if isOn { selectedMealTags.insert(mealType) }
                                    else { selectedMealTags.remove(mealType) }
                                }
                            ))
                        }
                    } // End of List for predefined meal types

                    HStack {
                        TextField("Add custom meal/occasion...", text: $newCustomMealTag)
                        Button("Add") {
                            let trimmedTag = newCustomMealTag.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedTag.isEmpty {
                                selectedMealTags.insert(trimmedTag)
                                newCustomMealTag = "" // Clear input field
                            }
                        }
                        .disabled(newCustomMealTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    if !selectedMealTags.isEmpty {
                        Text("Selected: \(selectedMealTags.sorted().joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                } // End of Meal/Occasion Tags Section
            } // End of Form
            .navigationTitle("Edit Tags for \(favorite.name)") // Dynamic title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Update the FavoriteRestaurant object's userDefined... properties
                        // The @Bindable wrapper ensures these changes are automatically
                        // reflected in the underlying @Model object and persisted by SwiftData.
                        favorite.userDefinedCuisineTags = Array(selectedCuisineTags).sorted()
                        favorite.userDefinedMealTags = Array(selectedMealTags).sorted()
                        
                        // Optional: Explicitly print to confirm
                        print("Saved User Cuisine Tags: \(favorite.userDefinedCuisineTags ?? [])")
                        print("Saved User Meal Tags: \(favorite.userDefinedMealTags ?? [])")

                        dismiss() // Dismiss the sheet
                    }
                }
            } // End of .toolbar
        } // End of NavigationView
    } // End of var body
} // End of struct EditFavoriteTagsView

// Helper extension (make sure this is OUTSIDE the EditFavoriteTagsView struct)
extension Array where Element: Hashable {
    func unique() -> [Element] {
        Array(Set(self))
    }
}
