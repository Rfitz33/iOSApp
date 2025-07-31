import SwiftUI

struct AddMovementEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var movements: [MovementEntry]
    var userProfile: UserProfile

    // Units and favorites system
    @AppStorage("units") private var units: String = "Metric"
    @AppStorage("favoriteMovements") private var favoriteMovementsData: Data = Data()
    @State private var favoriteMovements: [String] = []

    // Movement picker state
    @State private var selectedMovement: Movement = crossfitMovements.first!
    @State private var weight = ""
    @State private var reps = ""
    @State private var distance = ""
    @State private var useCustomROM = false
    @State private var customROM = ""
    @State private var ghdROMStandard: GHDROMStandard = .competition

    enum GHDROMStandard: String, CaseIterable, Identifiable {
        case competition = "Competition (Full ROM)"
        case standard = "Standard (Shoulder to Pad)"

        var id: String { rawValue }
        var ratio: Double {
            switch self {
            case .competition: return 0.33 // 33% of height (competition: touch floor)
            case .standard: return 0.22    // 22% of height (shoulder to pad/horizontal)
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // Movement Picker
                Section(header: Text("Movement")) {
                    CategorizedMovementPicker(selectedMovement: $selectedMovement, allMovements: crossfitMovements)
                }

                // Input fields
                Section(header: Text("Details")) {
                    // --- NEW LOGIC: Smart "Weight" Field Handling ---
                    if shouldShowWeightField(for: selectedMovement) {
                        TextField("Weight (\(units == "Metric" ? "kg" : "lbs"))", text: $weight)
                            .keyboardType(.decimalPad)
                            .onAppear {
                                if weight.isEmpty {
                                    let autoWeight = autofillWeight(for: selectedMovement, userProfile: userProfile)
                                    if autoWeight > 0 {
                                        weight = String(format: "%.0f", autoWeight)
                                    }
                                }
                            }
                        if !weightTooltip(for: selectedMovement).isEmpty {
                            HStack(alignment: .center, spacing: 6) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.accentColor)
                                Text(weightTooltip(for: selectedMovement))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 2)
                        }
                    }

                    TextField("Reps per round", text: $reps)
                        .keyboardType(.numberPad)
                        .help("Enter the number of repetitions of this movement in one round.")

                    // Special handling for GHD sit-ups
                    if isGHDSitUp(selectedMovement) {
                        Picker("ROM Standard", selection: $ghdROMStandard) {
                            ForEach(GHDROMStandard.allCases) { standard in
                                Text(standard.rawValue).tag(standard)
                            }
                        }
                        .pickerStyle(.segmented)
                        let defaultROM = calculatedDefaultROM(for: selectedMovement)
                        Text("Default ROM: \(formatROM(defaultROM)) \(units == "Metric" ? "m" : "ft")")
                            .foregroundColor(.secondary)
                            .help("Estimated vertical travel for your selected standard.")
                    }
                    // Standard distance field for "distance" movements (not GHD sit-up)
                    else if selectedMovement.requiresDistanceInput {
                        TextField("Distance per rep (\(units == "Metric" ? "m" : "ft"))", text: $distance)
                            .keyboardType(.decimalPad)
                            .help("Enter the distance traveled per rep for this movement.")
                    }
                    // All other movements
                    else {
                        Toggle("Override default ROM", isOn: $useCustomROM)
                            .help("Enable to enter a custom range of motion (ROM) value for this movement.")
                        if useCustomROM {
                            TextField("ROM (\(units == "Metric" ? "m" : "ft"))", text: $customROM)
                                .keyboardType(.decimalPad)
                                .help("Enter your personal range of motion for this movement.")
                        } else {
                            let rom = calculatedDefaultROM(for: selectedMovement)
                            Text("Default ROM: \(formatROM(rom)) \(units == "Metric" ? "m" : "ft")")
                                .foregroundColor(.secondary)
                                .help("Automatically estimated ROM for this movement based on your profile.")
                        }
                    }
                }

                Button("Add") {
                    let weightVal = Double(weight) ?? 0
                    let repsVal = Int(reps) ?? 0
                    var dist: Double = 0

                    if selectedMovement.requiresDistanceInput {
                        dist = Double(distance) ?? 0
                    } else if isGHDSitUp(selectedMovement) {
                        dist = calculatedDefaultROM(for: selectedMovement)
                    } else if useCustomROM {
                        dist = Double(customROM) ?? 0
                    } else {
                        dist = calculatedDefaultROM(for: selectedMovement)
                    }
                    // Convert to metric for calculations
                    let finalWeight = units == "Metric" ? weightVal : weightVal * 0.453592
                    let finalDist = units == "Metric" ? dist : dist * 0.3048

                    let entry = MovementEntry(
                        name: selectedMovement.name,
                        weight: finalWeight,
                        reps: repsVal,
                        distance: finalDist
                    )
                    movements.append(entry)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(
                    weight.isEmpty ||
                    reps.isEmpty ||
                    (selectedMovement.requiresDistanceInput && distance.isEmpty) ||
                    (!selectedMovement.requiresDistanceInput && useCustomROM && customROM.isEmpty)
                )
            }
            .navigationTitle("Add Movement")
            .onAppear { loadFavorites() }
        }
    }

    // MARK: - Favorites
    func loadFavorites() {
        if let decoded = try? JSONDecoder().decode([String].self, from: favoriteMovementsData) {
            favoriteMovements = decoded
        }
    }
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteMovements) {
            favoriteMovementsData = encoded
        }
    }
    func toggleFavorite(_ name: String) {
        if let idx = favoriteMovements.firstIndex(of: name) {
            favoriteMovements.remove(at: idx)
        } else {
            favoriteMovements.insert(name, at: 0)
        }
        saveFavorites()
    }

    // MARK: - Helper: Detect GHD Sit-up
    func isGHDSitUp(_ movement: Movement) -> Bool {
        let lowerName = movement.name.lowercased()
        return lowerName.contains("ghd") && lowerName.contains("sit")
    }

    // MARK: - ROM Logic (with GHD standard handling)
    func calculatedDefaultROM(for movement: Movement) -> Double {
        let lowerName = movement.name.lowercased()
        // Special handling for GHD Sit-up
        if isGHDSitUp(movement) {
            let heightInInches = userProfile.units == "Metric" ? userProfile.height / 2.54 : userProfile.height
            let romInInches = heightInInches * ghdROMStandard.ratio
            return units == "Metric" ? romInInches * 0.0254 : romInInches / 12.0
        }
        // All other logic unchanged from your existing mapping:
        if lowerName.contains("back squat") || lowerName.contains("front squat") || lowerName.contains("overhead squat") || lowerName.contains("wall ball") || lowerName.contains("bodyweight squat") {
            let value = ROMCalculator.squatROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("deadlift") {
            let value = ROMCalculator.deadliftROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("bench press") {
            let value = ROMCalculator.benchROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("pull-up") || lowerName.contains("chin-up") {
            let value = ROMCalculator.pullUpROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("strict press") || lowerName.contains("push press") || lowerName.contains("jerk") {
            let value = ROMCalculator.pressROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("thruster") {
            let value = ROMCalculator.thrusterROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("clean") && lowerName.contains("jerk") {
            let value = ROMCalculator.cleanAndJerkROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("snatch") {
            let value = ROMCalculator.snatchROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("clean") {
            let value = ROMCalculator.cleanROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("lunge") {
            let value = ROMCalculator.squatROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("burpee") {
            let value = ROMCalculator.burpeeROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        } else if lowerName.contains("box jump") {
            let value = ROMCalculator.boxJumpROMInFeet(boxHeight: 24, units: "Imperial")
            return units == "Metric" ? value * 0.3048 : value
        } else if movement.requiresDistanceInput {
            return 0.0
        } else {
            let value = ROMCalculator.defaultROMInFeet(profile: userProfile)
            return units == "Metric" ? value * 0.3048 : value
        }
    }

    func formatROM(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    // ---- New: Smart Weight Field Helpers ----

    func shouldShowWeightField(for movement: Movement) -> Bool {
        let name = movement.name.lowercased()
        // Hide for row, bike, ski erg
        if name.contains("row") || name.contains("bike") || name.contains("ski erg") {
            return false
        }
        // Show for all others
        return true
    }

    func autofillWeight(for movement: Movement, userProfile: UserProfile) -> Double {
        let name = movement.name.lowercased()
        // Bodyweight/gymnastics: autofill with user bodyweight
        if movement.category == .gymnastics ||
            name.contains("pull-up") ||
            name.contains("push-up") ||
            name.contains("muscle-up") ||
            name.contains("dip") ||
            name.contains("burpee") ||
            name.contains("toes-to-bar") ||
            name.contains("sit-up") ||
            name.contains("lunge") || // single leg bw lunge
            name.contains("step-up") ||
            name.contains("handstand push") ||
            name.contains("pistol") ||
            name.contains("air squat") ||
            name.contains("ghd")
        {
            return userProfile.weight
        }
        // Running: autofill bodyweight, allow edits
        if name.contains("run") {
            return userProfile.weight
        }
        // Farmer's Carry, Sled, Yoke, etc: blank (user must input)
        // Barbell, DB, KB: blank (user must input)
        return 0
    }

    func weightTooltip(for movement: Movement) -> String {
        let name = movement.name.lowercased()
        if movement.category == .gymnastics ||
            name.contains("pull-up") ||
            name.contains("push-up") ||
            name.contains("muscle-up") ||
            name.contains("dip") ||
            name.contains("burpee") ||
            name.contains("toes-to-bar") ||
            name.contains("sit-up") ||
            name.contains("lunge") || // single leg bw lunge
            name.contains("step-up") ||
            name.contains("handstand push") ||
            name.contains("pistol") ||
            name.contains("air squat") ||
            name.contains("ghd")
        {
            return "This is your bodyweight plus any added load (weight vest, belt, etc). Edit only if you used additional weight."
        }
        if name.contains("run") {
            return "If you carried or wore any additional weight (vest, backpack, sled, etc), enter total weight here. Otherwise, leave as your bodyweight."
        }
        if name.contains("carry") || name.contains("sled") || name.contains("yoke") {
            return "Enter total weight being carried or pushed (object + any load)."
        }
        if name.contains("row") || name.contains("bike") || name.contains("ski erg") {
            return ""
        }
        // Default for barbell/dumbbell/kettlebell:
        return "Enter weight on barbell, not bodyweight."
    }
}
