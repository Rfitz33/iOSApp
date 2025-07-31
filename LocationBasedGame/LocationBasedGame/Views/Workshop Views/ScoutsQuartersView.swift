// ScoutsQuartersView.swift
import SwiftUI

struct ScoutsQuartersView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    // State to control the presentation of the assignment picker sheet
    @State private var isShowingAssignmentSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // --- Header ---
                VStack(spacing: 8) {
                    Image("scouts_icon") // <-- Use a custom asset
                        .resizable().scaledToFit().frame(height: 80)
                    Text("Scouts' Quarters")
                        .font(.largeTitle.bold())
                    Text("Dispatch scouts to passively gather resources from the surrounding area.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center).padding(.horizontal)
                }
                .padding(.top)

                Divider()

                // --- Status Display ---
                MenuSection(title: "Current Expedition") {
                    VStack(spacing: 15) {
                        // Current Assignment
                        HStack {
                            Text("Assigned Task:")
                                .font(.headline)
                            Spacer()
                            if let task = gameManager.assignedScoutTask {
                                Image(task.inventoryIconAssetName)
                                    .resizable().scaledToFit().frame(width: 24, height: 24)
                                Text(task.displayName)
                                    .fontWeight(.bold)
                            } else {
                                Image(systemName: "shuffle.circle.fill")
                                Text("Random Basic")
                                    .fontWeight(.bold)
                            }
                        }
                        
                        // Return Timer
                        if let timer = gameManager.scoutsGatherTimer {
                            // We unwrap the timer itself, which IS optional.
                            // Then we can safely access its non-optional fireDate.
                             StatusRow(
                                 icon: "figure.walk.motion",
                                 iconColor: .brown,
                                 title: "Scout Status",
                                 statusPrefix: "Returning in:",
                                 date: timer.fireDate, // Pass the date directly
                                 statusColor: .green
                             )
                         } else {
                             // This correctly handles the case where the timer is nil (idle).
                             StatusRow(
                                 icon: "figure.stand",
                                 iconColor: .gray,
                                 title: "Scout Status",
                                 status: "Idle - Awaiting Assignment",
                                 statusColor: .secondary
                             )
                         }
                    }
                }
                
                Spacer()
                
                // --- Action Button ---
                Button {
                    isShowingAssignmentSheet = true
                } label: {
                    Text("Change Assignment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding()
            }
            .padding()
            .background(
                Image("scouts_quarters_background") // <-- Use a unique background
                    .resizable().scaledToFill().edgesIgnoringSafeArea(.all)
                    .overlay(Color.black.opacity(0.4))
            )
            .navigationTitle("Scouts' Quarters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
            // Present the assignment picker as a standard sheet
            .sheet(isPresented: $isShowingAssignmentSheet) {
                ScoutAssignmentView(gameManager: gameManager)
            }
        }
        .navigationViewStyle(.stack)
    }
}


// MARK: - Assignment Picker View
// We've moved the picker logic into its own dedicated view.
struct ScoutAssignmentView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) var dismiss
    
    @State private var pickerSelection: ScoutTaskSelection
    
    // Helper enum for the picker choices
    enum ScoutTaskSelection: Hashable, Identifiable {
        case none
        case specific(ResourceType)
        var id: String {
            switch self {
            case .none: return "none"
            case .specific(let type): return type.rawValue
            }
        }
        var displayName: String {
            switch self {
            case .none: return "Random Basic Resources"
            case .specific(let type): return type.displayName
            }
        }
    }
    
    // The list of available tasks
    private var taskOptions: [ScoutTaskSelection] {
        return [.none] + ResourceType.scoutGatherableTypes().map { .specific($0) }
    }
    
    // Initialize the picker to the current game state
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        if let assignedResource = gameManager.assignedScoutTask {
            self._pickerSelection = State(initialValue: .specific(assignedResource))
        } else {
            self._pickerSelection = State(initialValue: .none)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Assign Scout Task") {
                    Text("Choose a resource for your scout to focus on gathering, or select random to gather a mix of basic materials.")
                        .font(.caption).foregroundColor(.secondary)

                    Picker("Task", selection: $pickerSelection) {
                        ForEach(taskOptions) { option in
                            HStack {
                                if case .specific(let resource) = option {
                                    Image(resource.inventoryIconAssetName)
                                        .resizable().scaledToFit().frame(width: 24, height: 24)
                                } else {
                                    Image(systemName: "shuffle.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                Text(option.displayName)
                            }.tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                Section {
                    Button("Confirm & Deploy") {
                        switch pickerSelection {
                        case .none:
                            gameManager.assignAndDeployScout(selection: nil)
                        case .specific(let resource):
                            gameManager.assignAndDeployScout(selection: resource)
                        }
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Close") { dismiss() } }
            }
        }
    }
}


// MARK: - Preview Provider
struct ScoutsQuartersView_Previews: PreviewProvider {
    class MockScoutGameManager: GameManager {
        override init() {
            super.init()
            self.assignedScoutTask = .T1_wood
            self.activeBaseUpgrades.insert(.scoutsQuarters)
            // Start a mock timer for the preview
            self.startScoutsGatherTimer()
        }
    }
    static var previews: some View {
        ScoutsQuartersView(gameManager: MockScoutGameManager())
    }
}
