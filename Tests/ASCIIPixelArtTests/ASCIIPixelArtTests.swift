import Foundation
import Testing
import Color
@testable import ASCIIPixelArt

@Suite("ASCII Parser Tests")
struct ASCIIParserTests {
    @Test("Parse simple ASCII art")
    func parseSimple() {
        let ascii = """
        ##
        ##
        """
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 4)
    }

    @Test("Detect bounds")
    func detectBounds() {
        let ascii = """
        ###
        #
        ###
        """
        let (width, height) = ASCIIParser.bounds(of: ascii)
        #expect(width == 3)
        #expect(height == 3)
    }

    @Test("Custom fill characters")
    func customFillChars() {
        let ascii = "X.X"
        let pixels = ASCIIParser.parse(ascii, fillChars: ["X"])
        #expect(pixels.count == 2)
        #expect(pixels[0].x == 0)
        #expect(pixels[1].x == 2)
    }

    @Test("Empty input returns empty array")
    func emptyInput() {
        let pixels = ASCIIParser.parse("")
        #expect(pixels.isEmpty)
    }

    @Test("Empty lines preserved in bounds")
    func emptyLinesInBounds() {
        let ascii = "#\n\n#"
        let (width, height) = ASCIIParser.bounds(of: ascii)
        #expect(width == 1)
        #expect(height == 3)
    }

    @Test("All transparent characters")
    func allTransparent() {
        let ascii = "... ---"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.isEmpty)
    }

    @Test("Default fill characters")
    func defaultFillChars() {
        let ascii = "#*X@O"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 5)
    }
}

@Suite("PixelGrid Tests")
struct PixelGridTests {
    @Test("Create and access grid")
    func createAndAccess() {
        var grid = PixelGrid(width: 10, height: 10)
        grid[5, 5] = "#FF0000"
        #expect(grid[5, 5] == "#FF0000")
        #expect(grid[0, 0] == nil)
    }

    @Test("Out of bounds returns nil")
    func outOfBounds() {
        let grid = PixelGrid(width: 5, height: 5)
        #expect(grid[10, 10] == nil)
        #expect(grid[-1, -1] == nil)
    }

    @Test("Filled pixels enumeration")
    func filledPixels() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[0, 0] = "#FF0000"
        grid[2, 2] = "#00FF00"
        let filled = grid.filledPixels
        #expect(filled.count == 2)
    }

    @Test("JSON export produces valid JSON")
    func jsonExport() throws {
        var grid = PixelGrid(width: 2, height: 2)
        grid[0, 0] = "#FF0000"
        let json = try grid.toJSON()
        let decoded = try JSONDecoder().decode(PixelGrid.self, from: json)
        #expect(decoded.width == 2)
        #expect(decoded.height == 2)
        #expect(decoded[0, 0] == "#FF0000")
    }

    @Test("JSON round-trip encoding")
    func jsonRoundTrip() throws {
        var grid = PixelGrid(width: 5, height: 5)
        grid[1, 1] = "#AABBCC"
        grid[3, 3] = "#112233"
        let json = try grid.toJSON()
        let decoded = try JSONDecoder().decode(PixelGrid.self, from: json)
        #expect(decoded[1, 1] == "#AABBCC")
        #expect(decoded[3, 3] == "#112233")
        #expect(decoded[0, 0] == nil)
    }
}

@Suite("PixelGrid Color Integration Tests")
struct PixelGridColorTests {
    @Test("Set pixel with Color type")
    func setPixelWithColor() {
        var grid = PixelGrid(width: 5, height: 5)
        grid.setPixel(x: 2, y: 2, color: .red)
        #expect(grid[2, 2] != nil)
    }

    @Test("Get pixel as Color")
    func getPixelAsColor() {
        var grid = PixelGrid(width: 5, height: 5)
        grid[1, 1] = "#FF0000"
        let color = grid.color(at: 1, y: 1)
        #expect(color != nil)
    }

    @Test("Colored pixels enumeration")
    func coloredPixelsEnumeration() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[0, 0] = "#FF0000"
        grid[1, 1] = "#00FF00"
        let colored = grid.coloredPixels
        #expect(colored.count == 2)
    }

    @Test("Set nil color clears pixel")
    func setNilColorClearsPixel() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[1, 1] = "#FF0000"
        grid.setPixel(x: 1, y: 1, color: nil)
        #expect(grid[1, 1] == nil)
    }
}

@Suite("LayerMerger Tests")
struct LayerMergerTests {
    @Test("Merge layers by z-index")
    func mergeByZIndex() {
        let layer1 = Layer(pixels: [(0, 0)], color: "#FF0000", zIndex: 0)
        let layer2 = Layer(pixels: [(0, 0)], color: "#00FF00", zIndex: 1)

        let grid = LayerMerger.merge(layers: [layer1, layer2], width: 2, height: 2)

        // Higher z-index should win
        #expect(grid[0, 0] == "#00FF00")
    }

    @Test("Non-overlapping layers")
    func nonOverlapping() {
        let layer1 = Layer(pixels: [(0, 0)], color: "#FF0000", zIndex: 0)
        let layer2 = Layer(pixels: [(1, 1)], color: "#00FF00", zIndex: 1)

        let grid = LayerMerger.merge(layers: [layer1, layer2], width: 2, height: 2)

        #expect(grid[0, 0] == "#FF0000")
        #expect(grid[1, 1] == "#00FF00")
    }

    @Test("Empty layers array")
    func emptyLayers() {
        let grid = LayerMerger.merge(layers: [], width: 5, height: 5)
        #expect(grid.filledPixels.isEmpty)
    }

    @Test("Same z-index layers use order")
    func sameZIndex() {
        let layer1 = Layer(pixels: [(0, 0)], color: "#FF0000", zIndex: 0)
        let layer2 = Layer(pixels: [(0, 0)], color: "#00FF00", zIndex: 0)

        let grid = LayerMerger.merge(layers: [layer1, layer2], width: 2, height: 2)

        // Second layer should paint over first when z-index is equal
        #expect(grid[0, 0] == "#00FF00")
    }

    @Test("Pixels outside bounds are ignored")
    func pixelsOutsideBounds() {
        let layer = Layer(pixels: [(10, 10), (0, 0)], color: "#FF0000", zIndex: 0)
        let grid = LayerMerger.merge(layers: [layer], width: 5, height: 5)
        #expect(grid.filledPixels.count == 1)
        #expect(grid[0, 0] == "#FF0000")
    }

    @Test("Layer default z-index")
    func layerDefaultZIndex() {
        let layer = Layer(pixels: [(0, 0)], color: "#FF0000")
        #expect(layer.zIndex == 0)
    }
}

@Suite("SVGRenderer Tests")
struct SVGRendererTests {
    @Test("Render produces valid SVG")
    func renderProducesValidSVG() {
        var grid = PixelGrid(width: 2, height: 2)
        grid[0, 0] = "#FF0000"

        let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 100, canvasHeight: 100))

        #expect(svg.contains("<svg"))
        #expect(svg.contains("</svg>"))
        #expect(svg.contains("#FF0000"))
    }

    @Test("Render with background")
    func renderWithBackground() {
        let grid = PixelGrid(width: 2, height: 2)
        let svg = SVGRenderer.render(
            grid: grid,
            config: SVGConfig(canvasWidth: 100, canvasHeight: 100, backgroundColor: "#000000")
        )

        #expect(svg.contains("#000000"))
    }

    @Test("Render empty grid")
    func renderEmptyGrid() {
        let grid = PixelGrid(width: 5, height: 5)
        let svg = SVGRenderer.render(grid: grid)
        #expect(svg.contains("<svg"))
        #expect(svg.contains("</svg>"))
    }

    @Test("Render with default config")
    func renderWithDefaultConfig() {
        var grid = PixelGrid(width: 2, height: 2)
        grid[0, 0] = "#FF0000"
        let svg = SVGRenderer.render(grid: grid)
        #expect(svg.contains("256"))
    }
}

@Suite("SVGConfig Tests")
struct SVGConfigTests {
    @Test("Default configuration values")
    func defaultConfig() {
        let config = SVGConfig.default
        #expect(config.canvasWidth == 256)
        #expect(config.canvasHeight == 256)
        #expect(config.backgroundColor == nil)
    }

    @Test("Init with hex string background")
    func initWithHexBackground() {
        let config = SVGConfig(canvasWidth: 512, canvasHeight: 512, backgroundColor: "#FFFFFF")
        #expect(config.canvasWidth == 512)
        #expect(config.canvasHeight == 512)
        #expect(config.backgroundColor == "#FFFFFF")
    }

    @Test("Init with Color type background")
    func initWithColorBackground() {
        let config = SVGConfig(canvasWidth: 100, canvasHeight: 100, backgroundColor: .black)
        #expect(config.backgroundColor != nil)
    }

    @Test("Init with nil Color background")
    func initWithNilColorBackground() {
        let config = SVGConfig(canvasWidth: 100, canvasHeight: 100, backgroundColor: nil as Color?)
        #expect(config.backgroundColor == nil)
    }
}

@Suite("SVGBuilder Tests")
struct SVGBuilderTests {
    @Test("Document produces valid SVG structure")
    func documentProducesValidSVG() {
        let svg = SVGBuilder.document(width: 100, height: 200, content: "<rect/>")
        #expect(svg.contains("xmlns=\"http://www.w3.org/2000/svg\""))
        #expect(svg.contains("width=\"100\""))
        #expect(svg.contains("height=\"200\""))
        #expect(svg.contains("viewBox=\"0 0 100 200\""))
        #expect(svg.contains("<rect/>"))
    }

    @Test("Rect produces correct attributes")
    func rectProducesCorrectAttributes() {
        let rect = SVGBuilder.rect(x: 10.5, y: 20.5, width: 30, height: 40, fill: "#FF0000")
        #expect(rect.contains("x=\"10.5\""))
        #expect(rect.contains("y=\"20.5\""))
        #expect(rect.contains("width=\"30.0\""))
        #expect(rect.contains("height=\"40.0\""))
        #expect(rect.contains("fill=\"#FF0000\""))
    }

    @Test("Rect is self-closing")
    func rectIsSelfClosing() {
        let rect = SVGBuilder.rect(x: 0, y: 0, width: 10, height: 10, fill: "#000")
        #expect(rect.hasSuffix("/>"))
    }
}

// MARK: - Additional Edge Case Tests

@Suite("ASCIIParser Edge Cases")
struct ASCIIParserEdgeCaseTests {
    @Test("Unicode characters are ignored")
    func unicodeIgnored() {
        let ascii = "🎨#🎨"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 1)
    }

    @Test("Long lines handled correctly")
    func longLines() {
        let longLine = String(repeating: "#", count: 1000)
        let pixels = ASCIIParser.parse(longLine)
        #expect(pixels.count == 1000)
    }

    @Test("Whitespace-only input")
    func whitespaceOnly() {
        let ascii = "   \n   \n   "
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.isEmpty)
    }

    @Test("Mixed fill characters in same line")
    func mixedFillChars() {
        let ascii = "#*X@O"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 5)
        #expect(pixels[0].x == 0)
        #expect(pixels[4].x == 4)
    }

    @Test("Tab characters treated as non-fill")
    func tabCharacters() {
        let ascii = "#\t#"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 2)
    }

    @Test("Windows line endings")
    func windowsLineEndings() {
        // Note: Swift's split by \n leaves \r on each line
        // This test documents the actual behavior
        let ascii = "#\r\n#\r\n#"
        let pixels = ASCIIParser.parse(ascii)
        // Each line has a # that should be parsed
        #expect(pixels.count == 3)
    }

    @Test("Trailing newline")
    func trailingNewline() {
        let ascii = "##\n##\n"
        let (width, height) = ASCIIParser.bounds(of: ascii)
        #expect(width == 2)
        #expect(height == 3) // Empty line counts
    }

    @Test("Leading newlines")
    func leadingNewlines() {
        let ascii = "\n\n##"
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 2)
        #expect(pixels[0].y == 2)
    }
}

@Suite("PixelGrid Edge Cases")
struct PixelGridEdgeCaseTests {
    @Test("Large grid creation")
    func largeGrid() {
        let grid = PixelGrid(width: 1000, height: 1000)
        #expect(grid.width == 1000)
        #expect(grid.height == 1000)
    }

    @Test("1x1 grid")
    func singlePixelGrid() {
        var grid = PixelGrid(width: 1, height: 1)
        grid[0, 0] = "#FFFFFF"
        #expect(grid[0, 0] == "#FFFFFF")
        #expect(grid.filledPixels.count == 1)
    }

    @Test("Out-of-bounds set silently ignored")
    func outOfBoundsSetIgnored() {
        var grid = PixelGrid(width: 5, height: 5)
        grid[100, 100] = "#FF0000"
        grid[-1, -1] = "#00FF00"
        #expect(grid.filledPixels.isEmpty)
    }

    @Test("Negative coordinates return nil")
    func negativeCoords() {
        let grid = PixelGrid(width: 5, height: 5)
        #expect(grid[-1, 0] == nil)
        #expect(grid[0, -1] == nil)
        #expect(grid[-100, -100] == nil)
    }

    @Test("Non-square grid")
    func nonSquareGrid() {
        var grid = PixelGrid(width: 10, height: 3)
        grid[9, 2] = "#FF0000"
        #expect(grid[9, 2] == "#FF0000")
        #expect(grid[9, 3] == nil) // Out of bounds
    }

    @Test("Overwrite pixel")
    func overwritePixel() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[1, 1] = "#FF0000"
        grid[1, 1] = "#00FF00"
        #expect(grid[1, 1] == "#00FF00")
    }

    @Test("Clear pixel by setting nil")
    func clearPixel() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[1, 1] = "#FF0000"
        grid[1, 1] = nil
        #expect(grid[1, 1] == nil)
    }

    @Test("Filled pixels order is row-major")
    func filledPixelsOrder() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[2, 0] = "#A"
        grid[0, 0] = "#B"
        grid[1, 1] = "#C"
        let filled = grid.filledPixels
        // Should be ordered: (0,0), (2,0), (1,1)
        #expect(filled[0].x == 0 && filled[0].y == 0)
        #expect(filled[1].x == 2 && filled[1].y == 0)
        #expect(filled[2].x == 1 && filled[2].y == 1)
    }

    @Test("Color at invalid hex returns nil")
    func colorAtInvalidHex() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[1, 1] = "not-a-hex"
        // Color library returns nil for invalid hex
        #expect(grid.color(at: 1, y: 1) == nil)
        // But string is still stored
        #expect(grid[1, 1] == "not-a-hex")
    }
}

@Suite("SVGRenderer Edge Cases")
struct SVGRendererEdgeCaseTests {
    @Test("1x1 grid renders correctly")
    func singlePixel() {
        var grid = PixelGrid(width: 1, height: 1)
        grid[0, 0] = "#FF0000"
        let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 100, canvasHeight: 100))
        #expect(svg.contains("#FF0000"))
        #expect(svg.contains("width=\"100\""))
    }

    @Test("Non-square grid scales correctly")
    func nonSquareGrid() {
        var grid = PixelGrid(width: 4, height: 2)
        grid[0, 0] = "#FF0000"
        let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 400, canvasHeight: 200))
        // Pixel should be 100x100 (400/4 x 200/2)
        #expect(svg.contains("width=\"100.0\""))
        #expect(svg.contains("height=\"100.0\""))
    }

    @Test("Large canvas")
    func largeCanvas() {
        var grid = PixelGrid(width: 10, height: 10)
        grid[5, 5] = "#FFFFFF"
        let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 4096, canvasHeight: 4096))
        #expect(svg.contains("width=\"4096\""))
        #expect(svg.contains("height=\"4096\""))
    }

    @Test("Multiple pixels rendered")
    func multiplePixels() {
        var grid = PixelGrid(width: 3, height: 3)
        grid[0, 0] = "#FF0000"
        grid[1, 1] = "#00FF00"
        grid[2, 2] = "#0000FF"
        let svg = SVGRenderer.render(grid: grid)
        #expect(svg.contains("#FF0000"))
        #expect(svg.contains("#00FF00"))
        #expect(svg.contains("#0000FF"))
    }

    @Test("Background rect comes first")
    func backgroundFirst() {
        var grid = PixelGrid(width: 2, height: 2)
        grid[0, 0] = "#FFFFFF"
        let svg = SVGRenderer.render(
            grid: grid,
            config: SVGConfig(canvasWidth: 100, canvasHeight: 100, backgroundColor: "#000000")
        )
        // Background should appear before pixel
        let bgIndex = svg.range(of: "#000000")?.lowerBound
        let pixelIndex = svg.range(of: "#FFFFFF")?.lowerBound
        #expect(bgIndex != nil)
        #expect(pixelIndex != nil)
        #expect(bgIndex! < pixelIndex!)
    }
}

@Suite("Layer Edge Cases")
struct LayerEdgeCaseTests {
    @Test("Negative z-index")
    func negativeZIndex() {
        let layer = Layer(pixels: [(0, 0)], color: "#FF0000", zIndex: -10)
        #expect(layer.zIndex == -10)
    }

    @Test("Empty pixels array")
    func emptyPixels() {
        let layer = Layer(pixels: [], color: "#FF0000", zIndex: 0)
        #expect(layer.pixels.isEmpty)
    }

    @Test("Large z-index values")
    func largeZIndex() {
        let layer1 = Layer(pixels: [(0, 0)], color: "#FF0000", zIndex: Int.max)
        let layer2 = Layer(pixels: [(0, 0)], color: "#00FF00", zIndex: Int.min)
        let grid = LayerMerger.merge(layers: [layer1, layer2], width: 2, height: 2)
        #expect(grid[0, 0] == "#FF0000") // Max z-index wins
    }

    @Test("Negative pixel coordinates ignored in merge")
    func negativePixelCoords() {
        let layer = Layer(pixels: [(-1, -1), (0, 0)], color: "#FF0000", zIndex: 0)
        let grid = LayerMerger.merge(layers: [layer], width: 5, height: 5)
        #expect(grid.filledPixels.count == 1)
        #expect(grid[0, 0] == "#FF0000")
    }

    @Test("Many overlapping layers")
    func manyOverlappingLayers() {
        let layers = (0..<100).map { i in
            Layer(pixels: [(0, 0)], color: "#\(String(format: "%06X", i))", zIndex: i)
        }
        let grid = LayerMerger.merge(layers: layers, width: 2, height: 2)
        // Last layer (z-index 99) should win
        #expect(grid[0, 0] == "#000063")
    }
}

@Suite("Integration Tests")
struct IntegrationTests {
    @Test("Full ASCII to SVG workflow")
    func asciiToSVG() {
        // Create ASCII art
        let ascii = """
        ##
        ##
        """

        // Parse to pixels
        let pixels = ASCIIParser.parse(ascii)
        #expect(pixels.count == 4)

        // Get bounds
        let (width, height) = ASCIIParser.bounds(of: ascii)
        #expect(width == 2)
        #expect(height == 2)

        // Create layer
        let layer = Layer(pixels: pixels, color: "#FF0000", zIndex: 0)

        // Merge to grid
        let grid = LayerMerger.merge(layers: [layer], width: width, height: height)
        #expect(grid.filledPixels.count == 4)

        // Render to SVG
        let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 100, canvasHeight: 100))
        #expect(svg.contains("<svg"))
        #expect(svg.contains("</svg>"))
        #expect(svg.contains("#FF0000"))
    }

    @Test("Multi-layer composition")
    func multiLayerComposition() {
        let background = """
        ####
        ####
        """
        let foreground = """
        .##.
        .##.
        """

        let bgPixels = ASCIIParser.parse(background)
        let fgPixels = ASCIIParser.parse(foreground)

        let layers = [
            Layer(pixels: bgPixels, color: "#0000FF", zIndex: 0),
            Layer(pixels: fgPixels, color: "#FF0000", zIndex: 1)
        ]

        let grid = LayerMerger.merge(layers: layers, width: 4, height: 2)

        // Corners should be blue (background)
        #expect(grid[0, 0] == "#0000FF")
        #expect(grid[3, 0] == "#0000FF")

        // Center should be red (foreground)
        #expect(grid[1, 0] == "#FF0000")
        #expect(grid[2, 0] == "#FF0000")
    }

    @Test("Parse, modify, render")
    func parseModifyRender() {
        let ascii = "###"
        let pixels = ASCIIParser.parse(ascii)
        let (width, _) = ASCIIParser.bounds(of: ascii)

        var grid = PixelGrid(width: width, height: 1)
        for (x, y) in pixels {
            grid[x, y] = "#AABBCC"
        }

        // Modify one pixel
        grid[1, 0] = "#DDEEFF"

        let svg = SVGRenderer.render(grid: grid)
        #expect(svg.contains("#AABBCC"))
        #expect(svg.contains("#DDEEFF"))
    }
}
