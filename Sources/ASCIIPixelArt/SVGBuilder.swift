import Foundation

/// Low-level SVG element builder.
///
/// Provides static methods for creating SVG primitives as strings.
/// All methods are pure functions with no side effects.
public enum SVGBuilder {
    /// Creates a complete SVG document.
    ///
    /// - Parameters:
    ///   - width: Document width in pixels.
    ///   - height: Document height in pixels.
    ///   - content: SVG content elements.
    /// - Returns: Complete SVG document string.
    public static func document(width: Int, height: Int, content: String) -> String {
        """
        <svg xmlns="http://www.w3.org/2000/svg" width="\(width)" height="\(height)" viewBox="0 0 \(width) \(height)">
        \(content)
        </svg>
        """
    }

    /// Creates a rectangle element.
    ///
    /// - Parameters:
    ///   - x: X coordinate of top-left corner.
    ///   - y: Y coordinate of top-left corner.
    ///   - width: Rectangle width.
    ///   - height: Rectangle height.
    ///   - fill: Fill color (hex string like "#FF0000").
    /// - Returns: SVG rect element string.
    public static func rect(
        x: Double,
        y: Double,
        width: Double,
        height: Double,
        fill: String
    ) -> String {
        "<rect x=\"\(x)\" y=\"\(y)\" width=\"\(width)\" height=\"\(height)\" fill=\"\(fill)\"/>"
    }
}
