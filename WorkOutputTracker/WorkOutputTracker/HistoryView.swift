//
//  HistoryTabView.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/27/25.
//


import SwiftUI
import Foundation

struct WorkoutLogEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let workoutType: String
    let summary: String      // e.g. "5 Rounds, 13:00, 120 reps"
    let movements: [MovementEntry]
    let totalWork: Double?   // optional, in Joules
    let avgPower: Double?    // optional, in Watts
    // Add any other fields you want!
}

struct HistoryView: View {
    @State private var logs: [WorkoutLogEntry] = WorkoutHistoryStore.load()
    @ObservedObject var history = WorkoutHistoryStore.shared
    @Binding var showDetailForLogID: UUID?

    var body: some View {
            NavigationView {
                List {
                    ForEach(history.logs.sorted(by: { $0.date > $1.date })) { log in
                        NavigationLink(
                            destination: WorkoutDetailView(log: log),
                            tag: log.id,
                            selection: $showDetailForLogID
                        ) {
                            WorkoutSummaryRow(log: log)
                        }
                    }
                }
                .navigationTitle("History")
            }
            .onAppear {
                // Optionally clear selection after viewing
                // showDetailForLogID = nil
            }
        }
    }

struct WorkoutSummaryRow: View {
    let log: WorkoutLogEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text(log.date, style: .date)
                .font(.headline)
            Text(log.workoutType)
                .font(.subheadline)
            Text(log.summary)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// Detail view stub
struct WorkoutDetailView: View {
    let log: WorkoutLogEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Date: \(log.date.formatted(date: .long, time: .shortened))")
                Text("Type: \(log.workoutType)")
                Text("Summary: \(log.summary)")

                if let totalWork = log.totalWork {
                    Text("Total Work: \(String(format: "%.1f", totalWork)) J")
                }
                if let avgPower = log.avgPower {
                    Text("Average Power: \(String(format: "%.1f", avgPower)) W")
                }

                Divider()
                Text("Movements:")
                    .font(.headline)
                ForEach(log.movements, id: \.self) { move in
                    Text("\(move.name): \(move.reps) reps @ \(String(format: "%.1f", move.weight)) kg")
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
    }
}
