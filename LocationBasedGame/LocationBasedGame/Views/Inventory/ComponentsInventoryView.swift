//
//  ComponentsInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


import SwiftUI

struct ComponentsInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private var groupedComponents: [(category: ComponentCategory, items: [ComponentType])] {
        let owned = ComponentType.allCases.filter { gameManager.sanctumComponentStorage[$0] ?? 0 > 0 }
        let grouped = Dictionary(grouping: owned, by: { $0.category })
        return grouped.map { ($0.key, $0.value.sorted { $0.tier < $1.tier }) }.sorted { $0.0.displayOrder < $1.0.displayOrder }
    }
    
    var body: some View {
        List {
            if groupedComponents.isEmpty {
                Text("No components crafted.").foregroundColor(.secondary)
            } else {
                ForEach(groupedComponents, id: \.category) { categoryGroup in
                    Section(header: Text(categoryGroup.category.rawValue.capitalized)) {
                        ForEach(categoryGroup.items) { component in
                            Button(action: { selectedInspectableItem = .component(component) }) {
                                ComponentRowView(component: component, count: gameManager.sanctumComponentStorage[component] ?? 0)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Components")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}
