import SwiftUI

struct ProfileView: View {
    @State private var profile = UserProfile(
        name: "",
        sex: "Male",
        height: 170,
        weight: 70,
        units: "Metric",
        armLength: nil,
        legLength: nil
    )

    @State private var heightString: String = ""
    @State private var weightString: String = ""
    @State private var armLengthString: String = ""
    @State private var legLengthString: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Name", text: $profile.name)
                    Picker("Sex", selection: $profile.sex) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Physical Stats")) {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", text: $heightString)
                            .keyboardType(.decimalPad)
                        Text(profile.units == "Metric" ? "cm" : "in")
                    }
                    .onChange(of: heightString) {
                        profile.height = Double(heightString) ?? 0
                        saveProfile()
                    }
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                        Text(profile.units == "Metric" ? "kg" : "lbs")
                    }
                    .onChange(of: weightString) {
                        profile.weight = Double(weightString) ?? 0
                        saveProfile()
                    }
                    Picker("Units", selection: $profile.units) {
                        Text("Metric").tag("Metric")
                        Text("Imperial").tag("Imperial")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // ADVANCED LIMB LENGTH SECTION
                Section(header: Text("Advanced (Optional)")) {
                    TextField("Arm Length (\(profile.units == "Metric" ? "cm" : "in"))", text: $armLengthString)
                        .keyboardType(.decimalPad)
                        .help("Shoulder to fingertip, straight arm. Used to estimate range of motion for pressing and pulling movements.")
                        .onChange(of: armLengthString) {
                            profile.armLength = Double(armLengthString)
                            saveProfile()
                        }
                    TextField("Leg Length (\(profile.units == "Metric" ? "cm" : "in"))", text: $legLengthString)
                        .keyboardType(.decimalPad)
                        .help("Hip to floor, standing. Used to estimate range of motion for squats and lunges.")
                        .onChange(of: legLengthString) {
                            profile.legLength = Double(legLengthString)
                            saveProfile()
                        }
                }
            }
            .navigationTitle("Your Profile")
            .onAppear {
                loadProfile()
                heightString = profile.height > 0 ? String(profile.height) : ""
                weightString = profile.weight > 0 ? String(profile.weight) : ""
                armLengthString = profile.armLength != nil ? String(profile.armLength!) : ""
                legLengthString = profile.legLength != nil ? String(profile.legLength!) : ""
            }
            .onChange(of: profile) {
                saveProfile()
            }
        }
    }

    // Saving and loading
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    func loadProfile() {
        if let saved = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: saved) {
            profile = decoded
        }
    }
}
