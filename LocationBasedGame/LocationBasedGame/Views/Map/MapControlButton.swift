//
//  MapControlButton.swift
//  LocationBasedGame
//
//  Created by Reid on 6/2/25.
//


import SwiftUI

// MARK: - Custom Button Style for Map Controls
struct MapControlButton: ButtonStyle {
    var isActive: Bool = false // Add this property

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            // Use the 'isActive' property to change the background
            .background(isActive ? Color.blue : Color(.systemGray5).opacity(0.8))
            .clipShape(Circle())
            .shadow(radius: 2, y: 1)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Optional: Add a preview if you want to see the button style in isolation
struct MapControlButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Button {
                print("Map Control Button Tapped")
            } label: {
                Image(systemName: "location.fill")
            }
            .buttonStyle(MapControlButton())
            .padding()

            Button {
                print("Another Map Control Button Tapped")
            } label: {
                Image(systemName: "house.fill")
            }
            .buttonStyle(MapControlButton())
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.2))
    }
}
