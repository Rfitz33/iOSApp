//
//  BenchmarkWorkout.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/26/25.
//


import Foundation

struct BenchmarkWorkout: Identifiable {
    let id = UUID()
    let name: String
    let description: String // E.g. "21-15-9 Thrusters (95/65), Pull-ups, For time"
    let movements: [MovementEntry] // All movements with preset weights/reps
    let workoutType: WorkoutType
    let timeCap: Int? // In minutes, optional
}
