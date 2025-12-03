import Foundation
import Color

/**
 A 2D grid of pixels, each with an optional color.

 The grid uses a sparse representation where `nil` indicates transparency.
 Colors are stored as hex strings (e.g., "#FF0000").
 */
public struct PixelGrid: Codable, Sendable {
    /// Grid width in pixels.
    public let width: Int

    /// Grid height in pixels.
    public let height: Int

    /// 2D array of pixel colors. nil = transparent.
    public private(set) var pixels: [[String?]]

    /**
     Creates an empty grid with the specified dimensions.

     - Parameters:
       - width: Grid width in pixels.
       - height: Grid height in pixels.
     */
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.pixels = Array(
            repeating: Array(repeating: nil, count: width),
            count: height
        )
    }

    /**
     Access pixel color at coordinates.

     - Parameters:
       - x: X coordinate (0 = left).
       - y: Y coordinate (0 = top).
     - Returns: Hex color string or nil if transparent.
     */
    public subscript(x: Int, y: Int) -> String? {
        get {
            guard x >= 0, x < width, y >= 0, y < height else { return nil }
            return pixels[y][x]
        }
        set {
            guard x >= 0, x < width, y >= 0, y < height else { return }
            pixels[y][x] = newValue
        }
    }

    /**
     All non-transparent pixel coordinates with their colors.

     Returns pixels in row-major order (top to bottom, left to right).
     */
    public var filledPixels: [(x: Int, y: Int, color: String)] {
        var result: [(x: Int, y: Int, color: String)] = []
        for y in 0..<height {
            for x in 0..<width {
                if let color = pixels[y][x] {
                    result.append((x, y, color))
                }
            }
        }
        return result
    }

    /**
     Export as JSON data.

     The JSON structure includes width, height, and a flat array of pixels.
     - Returns: JSON-encoded data.
     */
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    // MARK: - Color Integration

    /**
     Set pixel color at coordinates using Color type.

     - Parameters:
       - x: X coordinate (0 = left).
       - y: Y coordinate (0 = top).
       - color: Color to set, or nil for transparent.
     */
    public mutating func setPixel(x: Int, y: Int, color: Color?) {
        self[x, y] = color?.hex
    }

    /**
     Get pixel color at coordinates as Color type.

     - Parameters:
       - x: X coordinate (0 = left).
       - y: Y coordinate (0 = top).
     - Returns: Color or nil if transparent/out of bounds.
     */
    public func color(at x: Int, y: Int) -> Color? {
        guard let hex = self[x, y] else { return nil }
        return Color(hex: hex)
    }

    /**
     All non-transparent pixels with Color objects.

     Returns pixels in row-major order (top to bottom, left to right).
     */
    public var coloredPixels: [(x: Int, y: Int, color: Color)] {
        filledPixels.compactMap { pixel in
            guard let color = Color(hex: pixel.color) else { return nil }
            return (pixel.x, pixel.y, color)
        }
    }
}
