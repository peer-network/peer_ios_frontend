//
//  UIImage+Crop.swift
//  PostCreation
//
//  Created by Artem Vasin on 31.08.25.
//

import UIKit

extension UIImage {
    /// Ensure pixel space matches what you see (orientation = .up)
    func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Returns image center-cropped to the given aspect ratio if it's not already close.
    func centerCroppedIfNeeded(to aspect: PostImagesAspectRatio, tolerance: CGFloat = 0.002) -> UIImage {
        let targetRatio: CGFloat = {
            switch aspect {
            case .square:   return 1.0           // width : height
            case .vertical: return 4.0 / 5.0     // width : height
            }
        }()

        guard let cg = self.normalizedUp().cgImage else { return self }

        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let current = w / h

        // Already close enough? Do nothing.
        if abs(current - targetRatio) <= tolerance {
            return UIImage(cgImage: cg, scale: scale, orientation: .up)
        }

        // Compute max centered rect with targetRatio that fits inside the image.
        let cropRect: CGRect
        if current > targetRatio {
            // Too wide → reduce width
            let cropW = round(h * targetRatio)
            let x = round((w - cropW) * 0.5)
            cropRect = CGRect(x: x, y: 0, width: cropW, height: h)
        } else {
            // Too tall → reduce height
            let cropH = round(w / targetRatio)
            let y = round((h - cropH) * 0.5)
            cropRect = CGRect(x: 0, y: y, width: w, height: cropH)
        }

        guard let cropped = cg.cropping(to: cropRect) else {
            return UIImage(cgImage: cg, scale: scale, orientation: .up)
        }
        return UIImage(cgImage: cropped, scale: scale, orientation: .up)
    }
}
