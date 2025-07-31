//
//  ToolsInventoryView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/22/25.
//


import SwiftUI

struct ToolsInventoryView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedInspectableItem: ItemDetailView.InspectableItem? = nil

    private let toolCategories: [ToolCategory] = [.pickaxe, .axe, .knife, .bow]

    var body: some View {
        List {
            ForEach(toolCategories, id: \.self) { category in
                let tools = ItemType.allCases.filter {
                    $0.toolCategory == category && (gameManager.sanctumItemStorage[$0] ?? 0) > 0
                }.sorted { $0.tier < $1.tier }

                if !tools.isEmpty {
                    Section(header: Text(category.rawValue.capitalized + "s")) {
                        ForEach(tools) { item in
                            Button(action: { selectedInspectableItem = .item(item) }) {
                                ToolRowView(gameManager: gameManager, item: item)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Tools")
        .sheet(item: $selectedInspectableItem) { item in
            ItemDetailView(gameManager: gameManager, inspectableItem: item)
        }
    }
}
