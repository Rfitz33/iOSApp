import SwiftUI

struct WorkoutsView: View {
    // Navigation handler (for switching tabs and showing the new log's detail)
    var onViewResults: ((UUID) -> Void)? = nil

    // MARK: - Workout State
    @State private var selectedWorkoutType: WorkoutType = .amrap

    // AMRAP
    @State private var amrapTime = ""
    @State private var movements: [MovementEntry] = []
    @State private var fullRounds = ""
    @State private var didCompletePartial = false
    @State private var partialReps: [String] = []

    // For Time
    @State private var forTimeRounds = "1"
    @State private var forTimeMin = ""
    @State private var forTimeSec = ""
    @State private var forTimePerRoundMin: [String] = []
    @State private var forTimePerRoundSec: [String] = []

    // For Weight
    @State private var sets = "1"
    @State private var forWeightReps = ""
    @State private var logEachSet = false
    @State private var setReps: [String] = []
    @State private var setWeights: [String] = []

    // EMOM
    @State private var emomMinutes = ""
    @State private var emomRounds = ""
    @State private var emomMovements: [MovementEntry] = []

    // Tabata
    @State private var tabataRounds = ""
    @State private var tabataMovements: [MovementEntry] = []

    // For Distance
    @State private var forDistanceValue = ""
    @State private var forDistanceMovements: [MovementEntry] = []

    // Not Timed
    @State private var notTimedDescription = ""
    @State private var notTimedMovements: [MovementEntry] = []

    // Add Movement Sheet
    @State private var showingAddMovement = false

    // Results
    @State private var totalWork: Double = 0
    @State private var avgPower: Double = 0

    var body: some View {
        NavigationView {
            Form {
                // Workout Type Picker
                Section(header: Text("Workout Type")) {
                    Picker("Workout Type", selection: $selectedWorkoutType) {
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // MARK: - AMRAP
                if selectedWorkoutType == .amrap {
                    Section(header: Text("AMRAP Setup")) {
                        TextField("AMRAP Time (minutes)", text: $amrapTime)
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Movements (reps per round)")) {
                        ForEach(movements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete(perform: removeMovement)
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $movements, userProfile: loadProfile())
                            }
                    }
                    if !movements.isEmpty {
                        Section(header: Text("Rounds Completed")) {
                            TextField("Full rounds completed", text: $fullRounds)
                                .keyboardType(.numberPad)
                            Toggle("Partial round?", isOn: $didCompletePartial)
                        }
                        if didCompletePartial {
                            Section(header: Text("Reps in partial round")) {
                                ForEach(movements.indices, id: \.self) { idx in
                                    HStack {
                                        Text(movements[idx].name)
                                        TextField("Reps in partial", text: partialRepsBinding(for: idx))
                                            .keyboardType(.numberPad)
                                            .frame(width: 60)
                                    }
                                }
                            }
                        }
                        Button("View Results") {
                            (totalWork, avgPower) = calculateAMRAPResults()
                            let summary = "\(fullRounds) rounds" +
                                (didCompletePartial ? " + partial" : "") +
                                " in \(amrapTime) min"
                            let logEntry = WorkoutLogEntry(
                                id: UUID(),
                                date: Date(),
                                workoutType: selectedWorkoutType.displayName,
                                summary: summary,
                                movements: movements,
                                totalWork: totalWork,
                                avgPower: avgPower
                            )
                            WorkoutHistoryStore.shared.add(logEntry)
                            onViewResults?(logEntry.id)
                            resetForm()
                        }
                        .disabled(fullRounds.isEmpty)
                    }
                }

                // MARK: - For Time
                if selectedWorkoutType == .forTime {
                    Section(header: Text("Rounds")) {
                        TextField("Number of rounds", text: $forTimeRounds)
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(movements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete(perform: removeMovement)
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $movements, userProfile: loadProfile())
                            }
                    }
                    if let rounds = Int(forTimeRounds), rounds > 1 {
                        Section(header: Text("Per-Round Times")) {
                            ForEach(0..<rounds, id: \.self) { idx in
                                HStack {
                                    Text("Round \(idx + 1):")
                                    TextField("min", text: $forTimePerRoundMin[safe: idx, default: ""])
                                        .keyboardType(.numberPad)
                                        .frame(width: 40)
                                    Text("min")
                                    TextField("sec", text: $forTimePerRoundSec[safe: idx, default: ""])
                                        .keyboardType(.numberPad)
                                        .frame(width: 40)
                                    Text("sec")
                                }
                            }
                        }
                    } else {
                        Section(header: Text("Total Time")) {
                            HStack {
                                TextField("Total min", text: $forTimeMin)
                                    .keyboardType(.numberPad)
                                    .frame(width: 40)
                                Text("min")
                                TextField("Total sec", text: $forTimeSec)
                                    .keyboardType(.numberPad)
                                    .frame(width: 40)
                                Text("sec")
                            }
                        }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateForTimeResults()
                        let summary = "\(forTimeRounds) rounds in \(forTimeMin):\(forTimeSec)"
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: movements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(forTimeRounds.isEmpty)
                }

                // MARK: - For Weight
                if selectedWorkoutType == .forWeight {
                    Section(header: Text("Sets & Reps")) {
                        TextField("Sets", text: $sets)
                            .keyboardType(.numberPad)
                        Toggle("Log each set separately", isOn: $logEachSet)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(movements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name)\(logEachSet ? "" : ": \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete(perform: removeMovement)
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $movements, userProfile: loadProfile())
                            }
                    }
                    if logEachSet, let numSets = Int(sets) {
                        Section(header: Text("Set Details")) {
                            ForEach(0..<numSets, id: \.self) { idx in
                                HStack {
                                    Text("Set \(idx + 1):")
                                    TextField("Reps", text: $setReps[safe: idx, default: ""])
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                    Text("x")
                                    TextField("Weight", text: $setWeights[safe: idx, default: ""])
                                        .keyboardType(.decimalPad)
                                        .frame(width: 70)
                                    Text("kg")
                                }
                            }
                        }
                    } else {
                        Section(header: Text("Reps")) {
                            TextField("Reps per set", text: $forWeightReps)
                                .keyboardType(.numberPad)
                        }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateForWeightResults()
                        let summary = "\(sets) sets\(logEachSet ? " (logged individually)" : "")"
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: movements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(sets.isEmpty)
                }

                // MARK: - EMOM
                if selectedWorkoutType == .emom {
                    Section(header: Text("EMOM Setup")) {
                        TextField("Minutes", text: $emomMinutes)
                            .keyboardType(.numberPad)
                        TextField("Rounds", text: $emomRounds)
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(emomMovements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete { emomMovements.remove(atOffsets: $0) }
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $emomMovements, userProfile: loadProfile())
                            }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateEMOMResults()
                        let summary = "\(emomRounds) rounds in \(emomMinutes) min"
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: emomMovements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(emomMinutes.isEmpty || emomRounds.isEmpty)
                }

                // MARK: - Tabata
                if selectedWorkoutType == .tabata {
                    Section(header: Text("Tabata Setup")) {
                        TextField("Rounds", text: $tabataRounds)
                            .keyboardType(.numberPad)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(tabataMovements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete { tabataMovements.remove(atOffsets: $0) }
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $tabataMovements, userProfile: loadProfile())
                            }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateTabataResults()
                        let summary = "\(tabataRounds) Tabata rounds"
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: tabataMovements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(tabataRounds.isEmpty)
                }

                // MARK: - For Distance
                if selectedWorkoutType == .forDistance {
                    Section(header: Text("Distance")) {
                        TextField("Distance", text: $forDistanceValue)
                            .keyboardType(.decimalPad)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(forDistanceMovements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete { forDistanceMovements.remove(atOffsets: $0) }
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $forDistanceMovements, userProfile: loadProfile())
                            }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateForDistanceResults()
                        let summary = "\(forDistanceValue) meters"
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: forDistanceMovements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(forDistanceValue.isEmpty)
                }

                // MARK: - Not Timed
                if selectedWorkoutType == .notTimed {
                    Section(header: Text("Description")) {
                        TextField("Workout description", text: $notTimedDescription)
                    }
                    Section(header: Text("Movements")) {
                        ForEach(notTimedMovements) { movement in
                            VStack(alignment: .leading) {
                                Text("\(movement.name): \(movement.reps) reps, \(String(format: "%.1f", movement.weight)) kg")
                                    .font(.subheadline)
                            }
                        }
                        .onDelete { notTimedMovements.remove(atOffsets: $0) }
                        Button("Add Movement") { showingAddMovement = true }
                            .sheet(isPresented: $showingAddMovement) {
                                AddMovementEntryView(movements: $notTimedMovements, userProfile: loadProfile())
                            }
                    }
                    Button("View Results") {
                        (totalWork, avgPower) = calculateNotTimedResults()
                        let summary = notTimedDescription
                        let logEntry = WorkoutLogEntry(
                            id: UUID(),
                            date: Date(),
                            workoutType: selectedWorkoutType.displayName,
                            summary: summary,
                            movements: notTimedMovements,
                            totalWork: totalWork,
                            avgPower: avgPower
                        )
                        WorkoutHistoryStore.shared.add(logEntry)
                        onViewResults?(logEntry.id)
                        resetForm()
                    }
                    .disabled(notTimedDescription.isEmpty)
                }
            }
            .navigationTitle("New Workout")
        }
    }

    // MARK: - Helpers

    func loadProfile() -> UserProfile {
        if let saved = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: saved) {
            return decoded
        }
        // Provide a fallback if no profile is saved yet
        return UserProfile(
            name: "Default",
            sex: "M",
            height: 70,
            weight: 180,
            units: "Imperial",
            armLength: nil
        )
    }


    func resetForm() {
        amrapTime = ""
        movements = []
        fullRounds = ""
        didCompletePartial = false
        partialReps = []
        forTimeRounds = "1"
        forTimeMin = ""
        forTimeSec = ""
        forTimePerRoundMin = []
        forTimePerRoundSec = []
        sets = "1"
        forWeightReps = ""
        logEachSet = false
        setReps = []
        setWeights = []
        emomMinutes = ""
        emomRounds = ""
        emomMovements = []
        tabataRounds = ""
        tabataMovements = []
        forDistanceValue = ""
        forDistanceMovements = []
        notTimedDescription = ""
        notTimedMovements = []
        totalWork = 0
        avgPower = 0
    }

    func removeMovement(at offsets: IndexSet) {
        movements.remove(atOffsets: offsets)
    }

    // For Partial Reps
    func partialRepsBinding(for idx: Int) -> Binding<String> {
        Binding<String>(
            get: {
                if idx < partialReps.count {
                    return partialReps[idx]
                } else {
                    return ""
                }
            },
            set: { newValue in
                if idx < partialReps.count {
                    partialReps[idx] = newValue
                } else {
                    // Fill up the array with "" until reaching idx
                    while partialReps.count < idx {
                        partialReps.append("")
                    }
                    partialReps.append(newValue)
                }
            }
        )
    }

    // MARK: - Calculation Stubs (Replace with real logic)
    func calculateAMRAPResults() -> (Double, Double) {
        // TODO: Replace with your actual calculation
        return (1000, 250)
    }
    func calculateForTimeResults() -> (Double, Double) {
        return (1200, 300)
    }
    func calculateForWeightResults() -> (Double, Double) {
        return (1500, 350)
    }
    func calculateEMOMResults() -> (Double, Double) {
        return (1100, 270)
    }
    func calculateTabataResults() -> (Double, Double) {
        return (800, 220)
    }
    func calculateForDistanceResults() -> (Double, Double) {
        return (1300, 360)
    }
    func calculateNotTimedResults() -> (Double, Double) {
        return (900, 180)
    }
}

// MARK: - Array Safe Subscript Extension
extension Binding where Value == [String] {
    subscript(safe index: Int, default defaultValue: String) -> Binding<String> {
        Binding<String>(
            get: {
                if index < wrappedValue.count {
                    return wrappedValue[index]
                } else {
                    return defaultValue
                }
            },
            set: { newValue in
                if index < wrappedValue.count {
                    wrappedValue[index] = newValue
                } else {
                    // Fill up the array with "" until reaching idx
                    while wrappedValue.count < index {
                        wrappedValue.append("")
                    }
                    wrappedValue.append(newValue)
                }
            }
        )
    }
}
