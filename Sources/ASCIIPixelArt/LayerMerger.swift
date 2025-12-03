import Foundation

/**
 A single color layer of ASCII art.

 Each layer represents a set of pixel coordinates that share the same color.
 Layers are composited by z-index, with higher values painting over lower.
 */
public struct Layer: Sendable {
    /// Pixel coordinates in this layer.
    public let pixels: [(x: Int, y: Int)]

    /// Layer color as hex string (e.g., "#FF0000").
    public let color: String

    /// Z-index for layer ordering. Lower = further back.
    public let zIndex: Int

    /**
     Creates a new layer.

     - Parameters:
       - pixels: Array of (x, y) coordinates.
       - color: Hex color string.
       - zIndex: Layer ordering (default: 0).
     */
    public init(pixels: [(x: Int, y: Int)], color: String, zIndex: Int = 0) {
        self.pixels = pixels
        self.color = color
        self.zIndex = zIndex
    }
}

/**
 Merges multiple layers into a single PixelGrid.

 Layers are composited in z-index order, with higher z-index values
 painting over lower ones (painter's algorithm).
 */
public enum LayerMerger {
    /**
     Merge layers into a grid.

     Higher zIndex layers paint over lower ones.

     - Parameters:
       - layers: Array of layers to merge.
       - width: Grid width.
       - height: Grid height.
     - Returns: Merged PixelGrid.
     */
    public static func merge(layers: [Layer], width: Int, height: Int) -> PixelGrid {
        var grid = PixelGrid(width: width, height: height)

        // Sort by z-index (lowest first, so highest paints last)
        let sorted = layers.sorted { $0.zIndex < $1.zIndex }

        for layer in sorted {
            for (x, y) in layer.pixels where x < width && y < height {
                grid[x, y] = layer.color
            }
        }

        return grid
    }

    /**
     Load layers from file paths with associated colors.

     - Parameter files: Array of (path, color, zIndex) tuples.
     - Returns: Array of parsed layers.
     - Throws: Error if file cannot be read.
     */
    public static func loadLayers(
        from files: [(path: String, color: String, zIndex: Int)]
    ) throws -> [Layer] {
        try files.map { file in
            let text = try String(contentsOfFile: file.path, encoding: .utf8)
            let pixels = ASCIIParser.parse(text)
            return Layer(pixels: pixels, color: file.color, zIndex: file.zIndex)
        }
    }

    /**
     Calculate combined bounds of multiple text files.

     - Parameter paths: Array of file paths.
     - Returns: (width, height) that contains all content.
     - Throws: Error if file cannot be read.
     */
    public static func combinedBounds(from paths: [String]) throws -> (width: Int, height: Int) {
        var maxWidth = 0
        var maxHeight = 0

        for path in paths {
            let text = try String(contentsOfFile: path, encoding: .utf8)
            let (width, height) = ASCIIParser.bounds(of: text)
            maxWidth = max(maxWidth, width)
            maxHeight = max(maxHeight, height)
        }

        return (maxWidth, maxHeight)
    }
}
