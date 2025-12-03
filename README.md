# SwiftASCII

[![macOS](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-ascii/macOS.yml?label=macOS&branch=main)](https://github.com/CorvidLabs/swift-ascii/actions/workflows/macOS.yml)
[![Ubuntu](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-ascii/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/CorvidLabs/swift-ascii/actions/workflows/ubuntu.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-ascii)](https://github.com/CorvidLabs/swift-ascii/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-ascii)](https://github.com/CorvidLabs/swift-ascii/releases)

A pure Swift package that converts ASCII art into pixel art SVG images.

## Features

- **Layer-based composition** - Merge multiple ASCII files with different colors
- **SVG output** - Scalable vector graphics, perfect for any size
- **JSON export** - Raw pixel grid data for further processing
- **Built on [swift-color](https://github.com/CorvidLabs/swift-color)** - Native Color type integration

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/CorvidLabs/swift-ascii", from: "0.1.0")
]
```

## Library Usage

### Single Layer

```swift
import ASCIIPixelArt

let ascii = """
  ##  ##
 ########
##########
 ########
  ######
   ####
    ##
"""

let pixels = ASCIIParser.parse(ascii)
let bounds = ASCIIParser.bounds(of: ascii)

var grid = PixelGrid(width: bounds.width, height: bounds.height)
for (x, y) in pixels {
    grid[x, y] = "#FF0000"
}

let svg = SVGRenderer.render(grid: grid, config: SVGConfig(canvasWidth: 256, canvasHeight: 256))
```

### Multi-Layer

```swift
let layers = try LayerMerger.loadLayers(from: [
    (path: "background.txt", color: "#87CEEB", zIndex: 0),
    (path: "body.txt",       color: "#FFD800", zIndex: 1),
    (path: "outline.txt",    color: "#000000", zIndex: 2),
])

let grid = LayerMerger.merge(layers: layers, width: 16, height: 16)
let svg = SVGRenderer.render(grid: grid)
let json = try grid.toJSON()
```

### Color Integration

```swift
import ASCIIPixelArt
import Color

var grid = PixelGrid(width: 10, height: 10)

// Set pixels using Color type
grid.setPixel(x: 0, y: 0, color: .red)
grid.setPixel(x: 1, y: 1, color: Color(hex: "#00FF00"))

// Read pixels as Color
if let color = grid.color(at: 0, y: 0) {
    print(color.hex) // "#FF0000"
}

// Configure SVG with Color background
let config = SVGConfig(
    canvasWidth: 256,
    canvasHeight: 256,
    backgroundColor: .black
)
let svg = SVGRenderer.render(grid: grid, config: config)
```

## CLI Usage

```bash
ascii-pixel-cli -o <name> [OPTIONS] <layer:color[:z-index]>...
```

### Options

| Option | Description |
|--------|-------------|
| `-o, --output <name>` | Output base name (creates .svg and .json) |
| `-s, --size <int>` | Canvas size in pixels (default: 256) |
| `-w, --width <int>` | Grid width (auto-detect if omitted) |
| `-h, --height <int>` | Grid height (auto-detect if omitted) |
| `--bg <color>` | Background color hex (default: transparent) |

### Examples

```bash
# Single layer - red heart
ascii-pixel-cli -o heart heart.txt:#FF0000

# Multi-layer sprite with z-order
ascii-pixel-cli -o sprite \
  background.txt:#87CEEB:0 \
  body.txt:#FFD800:1 \
  outline.txt:#000000:2

# Custom size with dark background
ascii-pixel-cli -o icon -s 512 --bg "#1A1A2E" art.txt:#FFFFFF
```

## Layer File Format

### Fill Characters

Characters that create a pixel:
- `#` `*` `X` `@` `O`

Characters that are transparent:
- Space, `.`, `-`

### Example File

```
  ##  ##
 ########
##########
##########
 ########
  ######
   ####
    ##
```

### Coordinate System

- Origin (0,0) at top-left
- X increases rightward
- Y increases downward
- Matches SVG coordinates

## API Reference

### PixelGrid

```swift
public struct PixelGrid: Codable, Sendable {
    public let width: Int
    public let height: Int
    public subscript(x: Int, y: Int) -> String? { get set }
    public var filledPixels: [(x: Int, y: Int, color: String)]
    public func toJSON() throws -> Data
}
```

### ASCIIParser

```swift
public enum ASCIIParser {
    public static func parse(_ text: String, fillChars: Set<Character>) -> [(x: Int, y: Int)]
    public static func bounds(of text: String) -> (width: Int, height: Int)
}
```

### LayerMerger

```swift
public struct Layer: Sendable {
    public let pixels: [(x: Int, y: Int)]
    public let color: String
    public let zIndex: Int
}

public enum LayerMerger {
    public static func merge(layers: [Layer], width: Int, height: Int) -> PixelGrid
    public static func loadLayers(from files: [(path: String, color: String, zIndex: Int)]) throws -> [Layer]
}
```

### SVGRenderer

```swift
public struct SVGConfig: Sendable {
    public let canvasWidth: Int
    public let canvasHeight: Int
    public let backgroundColor: String?
}

public enum SVGRenderer {
    public static func render(grid: PixelGrid, config: SVGConfig) -> String
}
```

## License

MIT
