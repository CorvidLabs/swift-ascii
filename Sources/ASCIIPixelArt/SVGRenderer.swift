import Foundation
import Color

/// Configuration for SVG rendering.
public struct SVGConfig: Sendable {
    /// Canvas width in pixels.
    public let canvasWidth: Int

    /// Canvas height in pixels.
    public let canvasHeight: Int

    /// Background color (nil = transparent).
    public let backgroundColor: String?

    /**
     Creates an SVG configuration.

     - Parameters:
       - canvasWidth: Output width in pixels (default: 256).
       - canvasHeight: Output height in pixels (default: 256).
       - backgroundColor: Background hex color or nil for transparent.
     */
    public init(
        canvasWidth: Int = 256,
        canvasHeight: Int = 256,
        backgroundColor: String? = nil
    ) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.backgroundColor = backgroundColor
    }

    /**
     Creates an SVG configuration with Color type for background.

     - Parameters:
       - canvasWidth: Output width in pixels (default: 256).
       - canvasHeight: Output height in pixels (default: 256).
       - backgroundColor: Background Color or nil for transparent.
     */
    public init(
        canvasWidth: Int = 256,
        canvasHeight: Int = 256,
        backgroundColor: Color?
    ) {
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.backgroundColor = backgroundColor?.hex
    }

    /// Default configuration (256x256, transparent).
    public static let `default` = SVGConfig()
}

/**
 Renders a PixelGrid to SVG.

 Converts grid pixels to SVG rectangles, scaling to fit the canvas size.
 */
public enum SVGRenderer {
    /**
     Render grid to SVG string.

     Each pixel becomes an SVG rectangle, scaled to fill the canvas.

     - Parameters:
       - grid: The pixel grid to render.
       - config: Rendering configuration.
     - Returns: Complete SVG document string.
     */
    public static func render(grid: PixelGrid, config: SVGConfig = .default) -> String {
        let pixelWidth = Double(config.canvasWidth) / Double(grid.width)
        let pixelHeight = Double(config.canvasHeight) / Double(grid.height)

        var elements: [String] = []

        // Background (optional)
        if let bg = config.backgroundColor {
            elements.append(SVGBuilder.rect(
                x: 0,
                y: 0,
                width: Double(config.canvasWidth),
                height: Double(config.canvasHeight),
                fill: bg
            ))
        }

        // Render each filled pixel
        for (x, y, color) in grid.filledPixels {
            elements.append(SVGBuilder.rect(
                x: Double(x) * pixelWidth,
                y: Double(y) * pixelHeight,
                width: pixelWidth,
                height: pixelHeight,
                fill: color
            ))
        }

        return SVGBuilder.document(
            width: config.canvasWidth,
            height: config.canvasHeight,
            content: elements.joined(separator: "\n")
        )
    }
}
