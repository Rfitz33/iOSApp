//
//  Debouncer.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//


import Foundation
import Combine // ObservableObject is from Combine

// MARK: - Debouncer
class Debouncer: ObservableObject { // Making it ObservableObject for @StateObject
    private var workItem: DispatchWorkItem?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        // Ensure the action is dispatched on the main thread if it updates UI
        // or interacts with main-thread-only properties.
        // The workItem itself will run on the queue it's scheduled on.
        // For @StateObject and UI updates, keeping it on main is good.
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}