//
//  FetchConfirmationView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/23/25.
//


// FetchConfirmationView.swift
import SwiftUI
import CoreLocation

struct FetchConfirmationView: View {
    @ObservedObject var gameManager: GameManager
    @ObservedObject var locationManager: LocationManager
    let node: ResourceNode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                if let pet = gameManager.activeCreature {
                    Text("Send Companion to Fetch?")
                        .font(.largeTitle.bold())
                    
                    // Companion Info
                    HStack {
                        Image("\(pet.type.rawValue)_icon")
                            .resizable().scaledToFit().frame(height: 60)
                        VStack(alignment: .leading) {
                            Text(pet.name ?? pet.type.displayName).font(.title2)
                            let charges = pet.fetchCharges
                            Text("Fetch Charges: \(charges) / \(pet.type.maxFetchCharges)")
                                .foregroundColor(charges > 0 ? .green : .red)
                        }
                    }
                    
                    Divider()
                    
                    // Resource Info
                    HStack {
                        Image(node.type.mapIconAssetName)
                            .resizable().scaledToFit().frame(height: 60)
                        Text(node.type.displayName).font(.title2)
                    }
                    
                    Spacer()
                    
                    // Action Button
                    Button {
                        if let playerLocation = locationManager.userLocation {
                            let result = gameManager.petFetchResource(node: node, playerLocation: playerLocation)
                                    // We also log the message here.
                            gameManager.logMessage(result.message, type: result.success ? .success : .failure)
                        }
                        dismiss()
                    } label: {
                        Text("Send to Fetch")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(gameManager.activeCreature?.fetchCharges ?? 0 == 0)

                } else {
                    Text("No Active Companion")
                        .font(.title)
                }
                Spacer()
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline) // Keep the title area compact
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss() // This tells the sheet to close
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct FetchConfirmationView_Previews: PreviewProvider {

    // MARK: - Mock Objects for Previewing
    
    class MockFetchGameManager: GameManager {
        override init() {
            super.init()
            var raven = Creature(type: .raven)
            raven.state = .trainedAdult
            raven.fetchCharges = 2
            self.ownedCreatures = [raven]
            self.activeCreatureID = raven.id
        }
    }
    
    class MockFetchLocationManager: LocationManager {
        // This can remain empty
    }

    // MARK: - Preview Scenarios

    static var previews: some View {
        // Using a Group to provide multiple previews
        Group {
            // --- Scenario 1: Standard Fetch (Charges Available) ---
            FetchConfirmationView(
                gameManager: MockFetchGameManager(),
                locationManager: MockFetchLocationManager(),
                node: ResourceNode(type: .T1_wood, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
            )
            .previewDisplayName("Charges Available")

            
            // --- Scenario 2: No Charges Left ---
            // The logic is now wrapped in a helper function or done inline.
            // The key is to return a View directly.
            FetchConfirmationView(
                gameManager: {
                    // Create the manager inside a closure
                    let manager = MockFetchGameManager()
                    if let ravenIndex = manager.ownedCreatures.firstIndex(where: { $0.type == .raven }) {
                        manager.ownedCreatures[ravenIndex].fetchCharges = 0
                        manager.ownedCreatures[ravenIndex].chargeRestoreTimes.append(Date().addingTimeInterval(60 * 5))
                    }
                    return manager // Return the configured manager
                }(), // Immediately execute the closure
                locationManager: MockFetchLocationManager(),
                node: ResourceNode(type: .T1_stone, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("No Charges Left (Dark)")
        }
    }
}
