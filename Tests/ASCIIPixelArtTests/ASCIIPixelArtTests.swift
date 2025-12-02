import Testing
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
}
