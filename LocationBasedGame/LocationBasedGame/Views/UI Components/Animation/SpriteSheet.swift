//
//  SpriteSheet.swift
//  LocationBasedGame
//
//  Created by Reid on 10/31/25.
//


// SpriteSheet.swift
import UIKit

/// A helper class to load a sprite sheet and provide access to its individual frames.
class SpriteSheet {
    /// An array of pre-sliced UIImage objects. Storing UIImages preserves the crucial scale factor.
    let frames: [UIImage]
    
    var frameCount: Int { frames.count }

    init?(imageName: String, frameCount: Int) {
        let traits = UITraitCollection(displayScale: UIScreen.main.scale)
        guard let masterImage = UIImage(named: imageName, in: nil, compatibleWith: traits),
              let masterCgImage = masterImage.cgImage,
              frameCount > 0 else {
            return nil
        }
        
        var croppedFrames: [UIImage] = []
        let frameWidthInPixels = masterCgImage.width / frameCount
        let frameHeightInPixels = masterCgImage.height
        
        for i in 0..<frameCount {
            let cropRect = CGRect(x: i * frameWidthInPixels,
                                  y: 0,
                                  width: frameWidthInPixels,
                                  height: frameHeightInPixels)
            
            if let frameCgImage = masterCgImage.cropping(to: cropRect) {
                // This is the critical step: we reconstruct a new UIImage from the cropped
                // pixel data, passing along the original image's scale factor.
                // This "re-applies" the lost scale information to each frame.
                let frameUiImage = UIImage(cgImage: frameCgImage,
                                           scale: masterImage.scale,
                                           orientation: .up)
                croppedFrames.append(frameUiImage)
            }
        }
        
        if croppedFrames.isEmpty {
            return nil
        }
        self.frames = croppedFrames
    }
}
