//
//  GardenView.swift
//  LocationBasedGame
//
//  Created by Reid on 6/18/25.
//

// GardenView.swift
import SwiftUI

struct GardenView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    // State to control the seed picker sheet
    @State private var plotToPlant: GardenPlot? = nil
    
    // Timer to keep the growth countdowns live
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // --- Header ---
                    VStack(spacing: 8) {
                        Image("garden_icon") // <-- A custom icon for the Garden
                            .resizable().scaledToFit().frame(height: 80)
                        Text("Garden")
                            .font(.largeTitle.bold())
                        Text("Cultivate rare seeds to grow a steady supply of valuable herbs.")
                            .font(.subheadline).foregroundColor(.secondary)
                            .multilineTextAlignment(.center).padding(.horizontal)
                    }
                    .padding(.vertical)

                    // --- Garden Plots Section ---
                    MenuSection(title: "Your Garden Plots") {
                        // Use a LazyVGrid for a nice, responsive grid layout
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(gameManager.gardenPlots) { plot in
                                GardenPlotView(
                                    gameManager: gameManager,
                                    plot: plot,
                                    currentTime: currentTime,
                                    onTap: {
                                        if plot.isEmpty {
                                            self.plotToPlant = plot
                                        } else {
                                            // Harvest logic is inside the plot view
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(
                Image("garden_background")
                    .resizable().scaledToFill().edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.3))
            )
            .navigationTitle("The Garden")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
            .onReceive(timer) { newTime in
                self.currentTime = newTime
            }
            // The sheet for picking a seed to plant
            .sheet(item: $plotToPlant) { plot in
                SeedPickerView(gameManager: gameManager, plotID: plot.id)
            }
        }
        .navigationViewStyle(.stack)
    }
}

// --- This view represents a single, tappable Garden Plot ---
struct GardenPlotView: View {
    @ObservedObject var gameManager: GameManager
    let plot: GardenPlot
    let currentTime: Date
    let onTap: () -> Void
    
    // Check if the plant is ready to be harvested
    private var isReadyToHarvest: Bool {
        guard let plantTime = plot.plantTime, let seed = plot.plantedSeed, let growthTime = seed.growthTime else {
            return false
        }
        return currentTime.timeIntervalSince(plantTime) >= growthTime
    }

    var body: some View {
        VStack(spacing: 8) {
            if let plantedSeed = plot.plantedSeed {
                // --- STATE: PLANTED ---
                Image(isReadyToHarvest ? (plantedSeed.correspondingHerb?.gardenIconAssetName ?? "plant_growing_icon") : "plant_growing_icon")
                    .resizable().scaledToFit()
                    .frame(height: 60)
                
                Text(plantedSeed.displayName)
                    .font(.caption.bold())
                
                if isReadyToHarvest {
                    Button("Harvest") {
                        let result = gameManager.harvestPlot(plotID: plot.id)
                        gameManager.feedbackPublisher.send(FeedbackEvent(message: result.message, isPositive: result.success))
                        gameManager.logMessage(result.message, type: result.success ? .success : .failure)
                    }
                    .buttonStyle(.borderedProminent).tint(.green).font(.caption)
                } else {
                    // Growth Timer
                    if let plantTime = plot.plantTime, let growthTime = plantedSeed.growthTime {
                        let harvestTime = plantTime.addingTimeInterval(growthTime)
                        Text(harvestTime, style: .timer)
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
            } else {
                // --- STATE: EMPTY ---
                Image("empty_plot_icon") // <-- custom asset for an empty plot
                    .resizable().scaledToFit()
                    .frame(height: 60)
                
                Text("Empty Plot")
                    .font(.caption.bold())
                
                Button("Plant") {
                    onTap()
                }
                .buttonStyle(.bordered).font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}


// --- This view is the sheet for picking a seed ---
struct SeedPickerView: View {
    @ObservedObject var gameManager: GameManager
    let plotID: UUID
    @Environment(\.dismiss) var dismiss
    
    // Find all seeds the player actually owns
    private var availableSeeds: [ResourceType] {
        gameManager.playerInventory.keys.filter {
            $0.correspondingHerb != nil && gameManager.playerInventory[$0, default: 0] > 0
        }.sorted { $0.tier < $1.tier }
    }
    
    var body: some View {
        NavigationView {
            List {
                if availableSeeds.isEmpty {
                    Text("You don't have any seeds. Find them by foraging for herbs in the wild.")
                        .foregroundColor(.secondary)
                } else {
                    Section("Select a Seed to Plant") {
                        ForEach(availableSeeds, id: \.self) { seed in
                            Button {
                                let result = gameManager.plantSeed(seed, inPlotID: plotID)
                                // We can use the potion message for this feedback
                                gameManager.lastPotionStatusMessage = result.message
                                dismiss()
                            } label: {
                                HStack {
                                    Image(seed.inventoryIconAssetName)
                                        .resizable().scaledToFit().frame(width: 32, height: 32)
                                    Text(seed.displayName)
                                    Spacer()
                                    Text("Owned: \(gameManager.playerInventory[seed, default: 0])")
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Seeds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
