import UIKit
import SwiftUI

extension UIImage {
    /// Extracts a vibrant dominant color from the image by sampling a small
    /// grid of pixels and averaging the most colorful (saturated) ones.
    var dominantColor: Color {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        let small = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }

        guard let cgImage = small.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return Color(red: 0.2, green: 0.2, blue: 0.3)
        }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let width  = cgImage.width
        let height = cgImage.height

        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        var count: CGFloat  = 0

        for y in 0 ..< height {
            for x in 0 ..< width {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let r = CGFloat(bytes[offset])     / 255
                let g = CGFloat(bytes[offset + 1]) / 255
                let b = CGFloat(bytes[offset + 2]) / 255

                // Skip near-black and near-white pixels
                let brightness = (r + g + b) / 3
                guard brightness > 0.08, brightness < 0.92 else { continue }

                // Weight by saturation so vivid colors contribute more
                let maxC = max(r, g, b)
                let minC = min(r, g, b)
                let saturation = maxC > 0 ? (maxC - minC) / maxC : 0
                let weight = 1 + saturation * 3

                totalR += r * weight
                totalG += g * weight
                totalB += b * weight
                count  += weight
            }
        }

        guard count > 0 else {
            return Color(red: 0.2, green: 0.2, blue: 0.3)
        }

        return Color(red: totalR / count,
                     green: totalG / count,
                     blue: totalB / count)
    }
}
