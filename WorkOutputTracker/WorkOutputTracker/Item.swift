//
//  Item.swift
//  WorkOutputTracker
//
//  Created by Reid on 5/25/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
