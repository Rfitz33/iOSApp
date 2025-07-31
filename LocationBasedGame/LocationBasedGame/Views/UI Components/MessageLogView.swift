//
//  MessageLogView.swift
//  LocationBasedGame
//
//  Created by Reid on 7/26/25.
//


// MessageLogView.swift
import SwiftUI

struct MessageLogView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        // ScrollViewReader allows us to programmatically scroll to the bottom.
        ScrollViewReader { proxy in
            // The ScrollView contains the list of messages.
            ScrollView(.vertical, showsIndicators: false) {
                // The LazyVStack is efficient for long lists of text.
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(gameManager.messageLog) { message in
                        HStack {
                            Text(message.text)
                                .font(.caption)
                                .foregroundColor(message.type.color)
                                .lineLimit(2) // Allow messages to wrap up to 2 lines
                            Spacer() // Pushes text to the left
                        }
                        .id(message.id) // Assign a unique ID to each row for scrolling
                    }
                }
                .padding(.vertical, 4) // Add some padding inside the scroll view
            }
            // This modifier watches for changes in the message log.
            .onReceive(gameManager.objectWillChange) { _ in
                // When anything in the GameManager changes, check if the log has a new message.
                if let lastMessageID = gameManager.messageLog.last?.id {
                    // Use a small delay to allow the view to update before we scroll.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation {
                            proxy.scrollTo(lastMessageID, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider for MessageLogView
struct MessageLogView_Previews: PreviewProvider {
    
    // A mock GameManager to provide sample data for the preview
    class MockLogGameManager: GameManager {
        override init() {
            super.init()
            logMessage("Gathered 5 Copper Ore!", type: .success)
            logMessage("Your scout returned with: 8x Glimmerwood.", type: .standard)
            logMessage("Too far to gather.", type: .failure)
            logMessage("Leveled up! Mining is now level 2.", type: .rare)
            logMessage("This is a much longer message to test how the text wraps inside the log view when it needs more than one line to display everything.", type: .standard)
            logMessage("Another successful gather.", type: .success)
            logMessage("One more for the road.", type: .standard)
        }
    }
    
    static var previews: some View {
        let mockManager = MockLogGameManager()
        
        MessageLogView(gameManager: mockManager)
            .frame(height: 120) // Give it a fixed height for previewing
            .background(Color.black.opacity(0.5))
            .preferredColorScheme(.dark)
    }
}
