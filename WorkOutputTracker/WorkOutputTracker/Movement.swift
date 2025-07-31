//
//  Movement.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/25/25.
//


import Foundation

enum MovementCategory: String, CaseIterable, Codable, Identifiable {
    case favorites = "Favorites"
    case squatLegs = "Squat & Legs"
    case olympic = "Olympic Lifts"
    case gymnastics = "Gymnastics/Bodyweight"
    case cardio = "Cardio/Mono-structural"
    case other = "Other"

    var id: String { rawValue }
}

struct Movement: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let category: MovementCategory
    let defaultDistanceMale: Double
    let defaultDistanceFemale: Double
    let requiresDistanceInput: Bool
}

// Example CrossFit movements
let crossfitMovements: [Movement] = [
    // SQUATS
    Movement(name: "Back Squat", category: .squatLegs, defaultDistanceMale: 0.62, defaultDistanceFemale: 0.60, requiresDistanceInput: false),
    Movement(name: "Front Squat", category: .squatLegs, defaultDistanceMale: 0.62, defaultDistanceFemale: 0.60, requiresDistanceInput: false),
    Movement(name: "Overhead Squat", category: .squatLegs, defaultDistanceMale: 0.62, defaultDistanceFemale: 0.60, requiresDistanceInput: false),
    // DEADLIFT & LUNGE
    Movement(name: "Deadlift", category: .squatLegs, defaultDistanceMale: 0.50, defaultDistanceFemale: 0.48, requiresDistanceInput: false),
    Movement(name: "Lunge", category: .squatLegs, defaultDistanceMale: 0.65, defaultDistanceFemale: 0.62, requiresDistanceInput: false),
    Movement(name: "Thruster", category: .squatLegs, defaultDistanceMale: 1.30, defaultDistanceFemale: 1.26, requiresDistanceInput: false),

    // PRESS & PULL
    Movement(name: "Strict Press", category: .olympic, defaultDistanceMale: 0.68, defaultDistanceFemale: 0.66, requiresDistanceInput: false),
    Movement(name: "Push Press", category: .olympic, defaultDistanceMale: 0.68, defaultDistanceFemale: 0.66, requiresDistanceInput: false),
    Movement(name: "Push Jerk", category: .olympic, defaultDistanceMale: 0.68, defaultDistanceFemale: 0.66, requiresDistanceInput: false),
    Movement(name: "Jerk", category: .olympic, defaultDistanceMale: 0.68, defaultDistanceFemale: 0.66, requiresDistanceInput: false),
    Movement(name: "Bench Press", category: .other, defaultDistanceMale: 0.60, defaultDistanceFemale: 0.58, requiresDistanceInput: false),
    Movement(name: "Pull-up", category: .gymnastics, defaultDistanceMale: 0.22, defaultDistanceFemale: 0.22, requiresDistanceInput: false),
    Movement(name: "Chin-up", category: .gymnastics, defaultDistanceMale: 0.22, defaultDistanceFemale: 0.22, requiresDistanceInput: false),

    // OLYMPIC LIFTS & HYBRIDS
    Movement(name: "Clean", category: .olympic, defaultDistanceMale: 0.50, defaultDistanceFemale: 0.48, requiresDistanceInput: false),
    Movement(name: "Clean & Jerk", category: .olympic, defaultDistanceMale: 1.18, defaultDistanceFemale: 1.14, requiresDistanceInput: false),
    Movement(name: "Snatch", category: .olympic, defaultDistanceMale: 1.14, defaultDistanceFemale: 1.10, requiresDistanceInput: false),

    // GYMNASTICS/BODYWEIGHT
    Movement(name: "Push-up", category: .gymnastics, defaultDistanceMale: 0.13, defaultDistanceFemale: 0.13, requiresDistanceInput: false),
    Movement(name: "Dip", category: .gymnastics, defaultDistanceMale: 0.18, defaultDistanceFemale: 0.17, requiresDistanceInput: false),
    Movement(name: "Ring Dip", category: .gymnastics, defaultDistanceMale: 0.18, defaultDistanceFemale: 0.17, requiresDistanceInput: false),
    Movement(name: "Muscle-up", category: .gymnastics, defaultDistanceMale: 0.60, defaultDistanceFemale: 0.57, requiresDistanceInput: false),
    Movement(name: "Handstand Push-up", category: .gymnastics, defaultDistanceMale: 0.13, defaultDistanceFemale: 0.13, requiresDistanceInput: false),
    Movement(name: "Toes-to-bar", category: .gymnastics, defaultDistanceMale: 0.32, defaultDistanceFemale: 0.31, requiresDistanceInput: false),
    Movement(name: "Knees-to-elbow", category: .gymnastics, defaultDistanceMale: 0.28, defaultDistanceFemale: 0.27, requiresDistanceInput: false),
    Movement(name: "Pistol Squat", category: .gymnastics, defaultDistanceMale: 0.62, defaultDistanceFemale: 0.60, requiresDistanceInput: false),
    Movement(name: "AbMat Sit-up", category: .gymnastics, defaultDistanceMale: 0.12, defaultDistanceFemale: 0.12, requiresDistanceInput: false),
    Movement(name: "GHD Sit-up", category: .gymnastics, defaultDistanceMale: 0.33, defaultDistanceFemale: 0.33, requiresDistanceInput: false),
    Movement(name: "Step-up", category: .gymnastics, defaultDistanceMale: 0.32, defaultDistanceFemale: 0.27, requiresDistanceInput: false),
    Movement(name: "Box Jump", category: .gymnastics, defaultDistanceMale: 0.32, defaultDistanceFemale: 0.27, requiresDistanceInput: false),

    // METERS OR DISTANCE TRAVELLED (User input for these)
    Movement(name: "Handstand Walk", category: .gymnastics, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Farmer's Carry", category: .other, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Sled Push", category: .squatLegs, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Burpee Broad Jump", category: .gymnastics, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Walking Lunge", category: .gymnastics, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Run", category: .cardio, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Row", category: .cardio, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Bike", category: .cardio, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Ski Erg", category: .cardio, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Jump Rope (Single-under)", category: .gymnastics, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true),
    Movement(name: "Jump Rope (Double-under)", category: .gymnastics, defaultDistanceMale: 0, defaultDistanceFemale: 0, requiresDistanceInput: true)
]


let girlWorkouts: [BenchmarkWorkout] = [
    BenchmarkWorkout(
        name: "Fran",
        description: "21-15-9 reps for time: Thrusters (95/65 lb), Pull-ups",
        movements: [
            MovementEntry(name: "Thruster", weight: 43.1, reps: 21, distance: 0), // 95 lbs to kg
            MovementEntry(name: "Pull-up", weight: 0, reps: 21, distance: 0)
            // For rounds 2 and 3, user just enters their total reps if scaling.
        ],
        workoutType: .forTime,
        timeCap: nil
    ),
    BenchmarkWorkout(
        name: "Grace",
        description: "30 Clean & Jerks (135/95 lb) for time",
        movements: [
            MovementEntry(name: "Clean & Jerk", weight: 61.2, reps: 30, distance: 0) // 135 lbs to kg
        ],
        workoutType: .forTime,
        timeCap: nil
    ),
    BenchmarkWorkout(
        name: "Helen",
        description: "3 rounds: 400m run, 21 Kettlebell Swings (24/16 kg), 12 Pull-ups",
        movements: [
            MovementEntry(name: "Run", weight: 0, reps: 1, distance: 400), // distance in meters
            MovementEntry(name: "Kettlebell Swing", weight: 24, reps: 21, distance: 0),
            MovementEntry(name: "Pull-up", weight: 0, reps: 12, distance: 0)
        ],
        workoutType: .forTime,
        timeCap: nil
    ),
    // Add more: Annie, Diane, Cindy, etc.
]

