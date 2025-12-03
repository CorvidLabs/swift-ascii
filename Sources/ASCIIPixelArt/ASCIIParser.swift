import Foundation

/**
 Parses ASCII art text into pixel coordinates.

 Converts text-based art into coordinate arrays that can be used
 to build a PixelGrid. Supports customizable fill characters.
 */
public enum ASCIIParser {
    /// Default characters that represent a filled pixel.
    public static let defaultFillChars: Set<Character> = ["#", "*", "X", "@", "O"]

    /**
     Parse ASCII text into pixel coordinates.

     Scans each character and records coordinates where fill characters appear.

     - Parameters:
       - text: The ASCII art text (newline-separated rows).
       - fillChars: Characters that count as "filled" pixels.
     - Returns: Array of (x, y) coordinates for filled pixels.
     */
    public static func parse(
        _ text: String,
        fillChars: Set<Character> = defaultFillChars
    ) -> [(x: Int, y: Int)] {
        var pixels: [(x: Int, y: Int)] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

        for (y, line) in lines.enumerated() {
            for (x, char) in line.enumerated() {
                if fillChars.contains(char) {
                    pixels.append((x, y))
                }
            }
        }
        return pixels
    }

    /**
     Detect the bounding box of ASCII art.

     Returns the dimensions needed to contain all content.

     - Parameter text: The ASCII art text.
     - Returns: Tuple of (width, height) in character units.
     */
    public static func bounds(of text: String) -> (width: Int, height: Int) {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let height = lines.count
        let width = lines.map { $0.count }.max() ?? 0
        return (width, height)
    }
}
