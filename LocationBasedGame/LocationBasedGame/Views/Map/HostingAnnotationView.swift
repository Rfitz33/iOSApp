//
//  HostingAnnotationView.swift
//  LocationBasedGame
//
//  Created by Reid on 10/30/25.
//


import MapKit
import SwiftUI

/// A custom MKAnnotationView that hosts a SwiftUI view.
final class HostingAnnotationView<Content: View>: MKAnnotationView {
    private var hostingController: UIHostingController<Content>?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.canShowCallout = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Sets or updates the SwiftUI view content for the annotation.
    func set(rootView: Content) {
        if let hostingController = hostingController {
            hostingController.rootView = rootView
        } else {
            let newHostingController = UIHostingController(rootView: rootView)
            newHostingController.view.backgroundColor = .clear
            self.addSubview(newHostingController.view)
            
            // Set constraints to make the hosting controller's view fill the annotation view.
            newHostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newHostingController.view.topAnchor.constraint(equalTo: self.topAnchor),
                newHostingController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                newHostingController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                newHostingController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])
            self.hostingController = newHostingController
        }
        // This is important for the annotation to size itself correctly based on the SwiftUI content.
        self.frame.size = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}