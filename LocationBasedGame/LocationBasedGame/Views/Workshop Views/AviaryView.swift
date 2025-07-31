// AviaryView.swift
import SwiftUI

struct AviaryView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    // Timer and current time for countdowns
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime = Date()

    var body: some View {
        NavigationView {
            List {
                // --- Section 1: Aviary Resources (Unchanged) ---
                aviaryResourcesSection

                // --- Section 2: The Perches ---
                // We create a dedicated section for each type of creature.
                petPerchSection(for: .raven)
                petPerchSection(for: .owl)
                petPerchSection(for: .hawk)
                petPerchSection(for: .dragon)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(
                Image("aviary_background").resizable().scaledToFill()
                    .edgesIgnoringSafeArea(.all).overlay(Color.black.opacity(0.4))
            )
            .navigationTitle("Aviary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
            .onReceive(timer) { newTime in
                self.currentTime = newTime
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // --- The "Perch" helper view builder ---
    @ViewBuilder
    private func petPerchSection(for creatureType: CreatureType) -> some View {
        // This function will render the entire section for a single pet type.
        
        // Find the state of this specific pet
        let eggResource = creatureType.eggResourceType
        let creatureInstance = gameManager.ownedCreatures.first { $0.type == creatureType }
        let incubationSlot = gameManager.incubatingSlots.first { $0.eggType == eggResource }
        let hasEggInInventory = (gameManager.playerInventory[eggResource] ?? 0) > 0

        MenuSection(title: creatureType.displayName) {
            // --- Now, decide what to display based on the state ---
            
            if let creature = creatureInstance {
                // STATE 1: Pet is Hatched (Hatchling, Untrained, or Trained)
                let row = CompanionRow(creature: creature, currentTime: currentTime, gameManager: gameManager)
                
                if gameManager.activeCreature?.id == creature.id {
                    // If it's active, show the row with a "Rest" button
                    HStack {
                        row
                        Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
                            .buttonStyle(.bordered).tint(.secondary).font(.caption)
                    }
                } else {
                    // If it's inactive, show the row (which has its own "Set Active" button)
                    row
                }
                
            } else if let slot = incubationSlot {
                // STATE 2: Egg is Incubating
                IncubationSlotView(gameManager: gameManager, slot: slot, currentTime: currentTime)
                
            } else if hasEggInInventory {
                // STATE 3: Egg is in inventory, ready to be incubated
                HStack {
                    Image(eggResource.inventoryIconAssetName)
                        .resizable().scaledToFit().frame(width: 32, height: 32)
                    Text("Unhatched \(creatureType.displayName) Egg")
                    Spacer()
                    if gameManager.incubatingSlots.count < gameManager.aviaryIncubationSlots {
                        Button("Incubate") {
                            let result = gameManager.startIncubation(eggType: eggResource)
                            gameManager.feedbackPublisher.send(FeedbackEvent(message: result.message, isPositive: result.success))
                            gameManager.logMessage(result.message, type: result.success ? .success : .standard)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text("Incubator Full").font(.caption).foregroundColor(.secondary)
                    }
                }
                
            } else {
                // STATE 4: Pet has not been discovered yet.
                Text("You have not discovered this creature yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    // --- Dedicated computed property for the resources section ---
    @ViewBuilder
    private var aviaryResourcesSection: some View {
        MenuSection(title: "Aviary Resources") {
            HStack {
                Image("feathers1")
                    .resizable().scaledToFit().frame(width: 32, height: 32)
                Text("Accumulated Feathers")
                Spacer()
                Button("Collect (\(gameManager.accumulatedFeathers))") {
                    _ = gameManager.collectFeathers()
                }
                .buttonStyle(.bordered)
                .disabled(gameManager.accumulatedFeathers == 0)
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private struct CompanionRow: View {
        let creature: Creature
        let currentTime: Date
        @ObservedObject var gameManager: GameManager

        var body: some View {
            switch creature.state {
            case .hatchling:
                HatchlingRowView(gameManager: gameManager, creature: creature, currentTime: currentTime)
            case .untrainedAdult:
                QuestRowView(gameManager: gameManager, creature: creature)
            case .trainedAdult:
                CreatureRowView(gameManager: gameManager, creature: creature, currentTime: currentTime)
            }
        }
    }
}

private struct IncubationSlotView: View {
    @ObservedObject var gameManager: GameManager
    let slot: IncubationSlot
    let currentTime: Date
    
    private var progress: Double {
        guard let creatureType = slot.creatureType else { return 0 }
        let timeElapsed = currentTime.timeIntervalSince(slot.incubationStartTime)
        return min(timeElapsed / creatureType.incubationTime, 1.0)
    }
    
    private var remainingTime: String {
        guard let creatureType = slot.creatureType else { return "???" }
        let timeElapsed = currentTime.timeIntervalSince(slot.incubationStartTime)
        let remaining = creatureType.incubationTime - timeElapsed
        if remaining <= 0 { return "Ready to Hatch!" }
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = (Int(remaining) % 3600) % 60
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%02dm %02ds", minutes, seconds)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(slot.eggType.inventoryIconAssetName)
                    .resizable().scaledToFit().frame(width: 40, height: 40)
                Text(slot.eggType.displayName).font(.headline)
            }
            ProgressView(value: progress)
            HStack {
                Text(remainingTime)
                    .font(.caption).foregroundColor(.secondary)
                Spacer()
                if progress >= 1.0 {
                    Button("Hatch") {
                        let result = gameManager.hatchEgg(slotID: slot.id)
                        gameManager.lastPotionStatusMessage = result.message
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Computed Properties for UI Sections
//    @ViewBuilder
//    private var activeCompanionSection: some View {
//        // This section only appears if a pet is active.
//        if let activeCreature = gameManager.activeCreature {
//            MenuSection(title: "Active Companion") {
//                // Use a switch to show the correct detailed view for the active pet
//                switch activeCreature.state {
//                case .hatchling:
//                    HStack {
//                            HatchlingRowView(gameManager: gameManager, creature: activeCreature, currentTime: currentTime)
//                            Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                                .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                        }
//                case .untrainedAdult:
//                    HStack {
//                           QuestRowView(gameManager: gameManager, creature: activeCreature)
//                           Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                               .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                       }
//                case .trainedAdult:
//                    HStack {
//                            CreatureRowView(gameManager: gameManager, creature: activeCreature, currentTime: currentTime)
//                            Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                                .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                        }
//                }
//            }
//            .listRowBackground(Color.clear)
//            .listRowSeparator(.hidden)
//        }
//    }

//    @ViewBuilder
//    private var incubatorAndInventorySection: some View {
//        MenuSection(title: "Incubation & Eggs") {
//            if gameManager.incubatingSlots.isEmpty {
//                Text("No eggs are currently incubating.").font(.caption).foregroundColor(.secondary)
//            } else {
//                ForEach(gameManager.incubatingSlots) { slot in
//                    IncubationSlotView(gameManager: gameManager, slot: slot, currentTime: self.currentTime)
//                }
//            }
//
//            Divider()
//
//            let availableEggs = gameManager.playerInventory.keys
//                .filter { $0.tags?.contains(.egg) == true && gameManager.playerInventory[$0, default: 0] > 0 }
//                .sorted(by: { $0.tier < $1.tier })
//
//            if availableEggs.isEmpty {
//                Text("You have no eggs in your inventory.").font(.caption).foregroundColor(.secondary)
//            } else {
//                ForEach(availableEggs, id: \.self) { eggType in
//                    HStack {
//                        Image(eggType.inventoryIconAssetName)
//                            .resizable().scaledToFit().frame(width: 32, height: 32)
//                        Text(eggType.displayName)
//                        Spacer()
//                        if gameManager.incubatingSlots.count < gameManager.aviaryIncubationSlots {
//                            Button("Incubate") {
//                                let result = gameManager.startIncubation(eggType: eggType)
//                                gameManager.feedbackPublisher.send(FeedbackEvent(message: result.message, isPositive: result.success))
//                                gameManager.logMessage(result.message, type: result.success ? .success : .standard)
//                            }
//                            .buttonStyle(.bordered)
//                        }
//                    }
//                }
//            }
//        }
//        .listRowBackground(Color.clear)
//        .listRowSeparator(.hidden)
//    }

//@ViewBuilder
//    private var allCompanionsSection: some View {
//        // We only create the section if there are companions to show.
//        if !gameManager.ownedCreatures.isEmpty {
//            MenuSection(title: "All Companions") {
//                // The ForEach loop is now directly inside the MenuSection.
//                ForEach(gameManager.ownedCreatures) { creature in
//                    // We use a helper view to handle the switch statement.
//                    CompanionRow(creature: creature, currentTime: currentTime, gameManager: gameManager)
//                }
//            }
//            .listRowBackground(Color.clear)
//            .listRowSeparator(.hidden)
//        }
//    }
    
    // MARK: - View Sections
    
    // --- NEW: Add this @ViewBuilder computed property inside AviaryView ---
//    @ViewBuilder
//    private var activeCompanionSection: some View {
//        // This section only appears if a pet is active.
//        if let activeCreature = gameManager.activeCreature {
//            Section(header: Text("Active Companion")) {
//                // --- NEW: Switch on the pet's state to show the correct detailed view ---
//                switch activeCreature.state {
//                case .hatchling:
//                    // We show the hatchling view, but add the "Rest" button.
//                    HStack {
//                        HatchlingRowView(gameManager: gameManager, creature: activeCreature, currentTime: currentTime)
//                        Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                            .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                    }
//                case .untrainedAdult:
//                    // We show the full quest view, but add the "Rest" button.
//                    HStack {
//                        QuestRowView(gameManager: gameManager, creature: activeCreature)
//                        Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                            .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                    }
//                case .trainedAdult:
//                    // We show the full trained view, but add the "Rest" button.
//                    HStack {
//                        CreatureRowView(gameManager: gameManager, creature: activeCreature)
//                        Button("Rest") { gameManager.setActiveCreature(creatureID: nil) }
//                            .buttonStyle(.bordered).tint(.secondary).font(.caption)
//                    }
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var incubatorSection: some View {
//        Section(header: Text("Incubator Slots (\(gameManager.incubatingSlots.count)/\(gameManager.aviaryIncubationSlots))")) {
//            if gameManager.incubatingSlots.isEmpty {
//                Text("No eggs are currently incubating.")
//                    .foregroundColor(.secondary)
//            } else {
//                ForEach(gameManager.incubatingSlots) { slot in
//                    IncubationSlotView(gameManager: gameManager, slot: slot, currentTime: self.currentTime)
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var inventoryEggsSection: some View {
//        Section(header: Text("Eggs in Inventory")) {
//            // --- CORRECTION: Calculate the array HERE, inside the view body ---
//            let availableEggs = gameManager.playerInventory.keys
//                .filter { $0.tags?.contains(.egg) == true && gameManager.playerInventory[$0, default: 0] > 0 }
//                .sorted(by: { $0.tier < $1.tier })
//            
//            if availableEggs.isEmpty {
//                Text("You have no eggs in your inventory.")
//                    .foregroundColor(.secondary)
//            } else {
//                // --- CORRECTION: Loop over the calculated array ---
//                ForEach(availableEggs, id: \.self) { eggType in
//                    HStack {
//                        Image(eggType.inventoryIconAssetName)
//                            .resizable().scaledToFit().frame(width: 32, height: 32)
//                        Text(eggType.displayName)
//                        Spacer()
//                        if gameManager.incubatingSlots.count < gameManager.aviaryIncubationSlots {
//                            Button("Incubate") {
//                                let result = gameManager.startIncubation(eggType: eggType)
//                                gameManager.lastPotionStatusMessage = result.message
//                            }
//                            .buttonStyle(.bordered)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var companionsSection: some View {
//        // Filter out the active pet from the main list to avoid duplication.
//        let inactiveCompanions = gameManager.ownedCreatures.filter { $0.id != gameManager.activeCreatureID }
//        
//        // The section header can now just be a generic title.
//        Section(header: Text("Your Companions")) {
//            if gameManager.ownedCreatures.isEmpty {
//                Text("You do not have any companions yet.")
//                    .foregroundColor(.secondary)
//            } else if inactiveCompanions.isEmpty && gameManager.activeCreature != nil {
//                Text("Your active companion is shown above.")
//                    .foregroundColor(.secondary)
//            } else {
//                // Loop through the filtered list.
//                ForEach(inactiveCompanions) { creature in
//                    switch creature.state {
//                    case .hatchling:
//                        HatchlingRowView(gameManager: gameManager, creature: creature, currentTime: self.currentTime)
//                    case .untrainedAdult:
//                        QuestRowView(gameManager: gameManager, creature: creature)
//                    case .trainedAdult:
//                        CreatureRowView(gameManager: gameManager, creature: creature)
//                    }
//                }
//            }
//        }
//    }
    
