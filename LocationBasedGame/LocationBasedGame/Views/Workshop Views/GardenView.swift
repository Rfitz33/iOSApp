//
//  GardenView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

import SwiftUI
struct GardenView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Text("Garden Actions - Coming Soon!")
                .navigationTitle("Garden")
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }}}
        }
    }
}
