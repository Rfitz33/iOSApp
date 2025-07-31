//
//  ResourcesInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


import SwiftUI

struct ResourcesInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private var groupedResources: [(category: ResourceCategory, items: [ResourceType])] {
        let owned = ResourceType.allCases.filter { gameManager.playerInventory[$0] ?? 0 > 0 }
        let grouped = Dictionary(grouping: owned, by: { $0.category })
        return grouped.map { ($0.key, $0.value.sorted { $0.tier < $1.tier }) }.sorted { $0.0.displayOrder < $1.0.displayOrder }
    }
    
    var body: some View {
        List {
            if groupedResources.isEmpty {
                Text("No resources gathered.").foregroundColor(.secondary)
            } else {
                ForEach(groupedResources, id: \.category) { categoryGroup in
                    Section(header: Text(categoryGroup.category.rawValue.capitalized)) {
                        ForEach(categoryGroup.items) { resource in
                            Button(action: { selectedInspectableItem = .resource(resource) }) {
                                ResourceRowView(resource: resource, count: gameManager.playerInventory[resource] ?? 0)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Resources")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}