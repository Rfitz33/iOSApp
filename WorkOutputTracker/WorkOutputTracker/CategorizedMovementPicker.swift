import SwiftUI

struct CategorizedMovementPicker: View {
    @Binding var selectedMovement: Movement
    @AppStorage("favoriteMovements") private var favoriteMovementsData: Data = Data()
    @State private var favoriteNames: [String] = []

    @State private var searchText = ""
    @State private var expanded: [MovementCategory: Bool] = {
        var dict: [MovementCategory: Bool] = [:]
        for cat in MovementCategory.allCases {
            dict[cat] = false
        }
        return dict
    }()

    var allMovements: [Movement]

    // Search logic
    var filteredMovements: [Movement] {
        if searchText.isEmpty { return allMovements }
        return allMovements.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var favorites: [Movement] {
        filteredMovements.filter { favoriteNames.contains($0.name) }
    }

    var movementsByCategory: [MovementCategory: [Movement]] {
        Dictionary(grouping: filteredMovements) { $0.category }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search movements...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.horizontal, .top])

                List {
                    // FAVORITES CATEGORY at top
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expanded[.favorites, default: false] },
                            set: { expanded[.favorites] = $0 }
                        ),
                        content: {
                            if favorites.isEmpty {
                                Text("No favorites yet.").foregroundColor(.secondary)
                            } else {
                                ForEach(favorites) { movement in
                                    MovementRow(
                                        movement: movement,
                                        isFavorite: true,
                                        selected: movement == selectedMovement,
                                        select: { select(movement) },
                                        toggleFavorite: { toggleFavorite(movement.name) }
                                    )
                                }
                            }
                        },
                        label: {
                            Text("Favorites").font(.headline)
                        }
                    )

                    // ALL OTHER CATEGORIES
                    ForEach(MovementCategory.allCases.filter { $0 != .favorites }, id: \.self) { category in
                        let movements = movementsByCategory[category, default: []]
                        if !movements.isEmpty {
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expanded[category, default: false] },
                                    set: { expanded[category] = $0 }
                                ),
                                content: {
                                    ForEach(movements) { movement in
                                        MovementRow(
                                            movement: movement,
                                            isFavorite: favoriteNames.contains(movement.name),
                                            selected: movement == selectedMovement,
                                            select: { select(movement) },
                                            toggleFavorite: { toggleFavorite(movement.name) }
                                        )
                                    }
                                },
                                label: {
                                    Text(category.rawValue).font(.headline)
                                }
                            )
                        }
                    }

                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Pick Movement")
            .onAppear(perform: loadFavorites)
        }
    }

    // MARK: - Helpers

    func select(_ movement: Movement) {
        selectedMovement = movement
    }

    func loadFavorites() {
        if let decoded = try? JSONDecoder().decode([String].self, from: favoriteMovementsData) {
            favoriteNames = decoded
        }
    }
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteNames) {
            favoriteMovementsData = encoded
        }
    }
    func toggleFavorite(_ name: String) {
        if let idx = favoriteNames.firstIndex(of: name) {
            favoriteNames.remove(at: idx)
        } else {
            favoriteNames.insert(name, at: 0)
        }
        saveFavorites()
    }
}

// MARK: - Row View

struct MovementRow: View {
    let movement: Movement
    let isFavorite: Bool
    let selected: Bool
    let select: () -> Void
    let toggleFavorite: () -> Void

    var body: some View {
        HStack {
            Button(action: select) {
                HStack {
                    Text(movement.name)
                        .foregroundColor(.primary)
                    if selected {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(8)
                .background(selected ? Color.accentColor.opacity(0.15) : Color.clear)
                .cornerRadius(8)
            }
            Spacer()
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

