//
//  RoundedCorner.swift
//  LocationBasedGame
//
//  Created by Reid on 6/8/25.
//
import SwiftUI

// Helper for rounding specific corners (if needed for bottom panel)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
