//
//  WorkoutHistoryStore.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/27/25.
//


import Foundation

class WorkoutHistoryStore: ObservableObject {
    @Published var logs: [WorkoutLogEntry] = []

    static let shared = WorkoutHistoryStore()
    
    init() {
        logs = Self.load()
    }

    static let filename = "workout_logs.json"
    static private func logsFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
    static func load() -> [WorkoutLogEntry] {
        let url = logsFileURL()
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([WorkoutLogEntry].self, from: data)) ?? []
    }
    static func save(_ logs: [WorkoutLogEntry]) {
        let url = logsFileURL()
        if let data = try? JSONEncoder().encode(logs) {
            try? data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        }
    }
    func add(_ entry: WorkoutLogEntry) {
        logs.append(entry)
        Self.save(logs)
    }
}

