import Foundation
import ASCIIPixelArt

// MARK: - Main Entry Point

let args = Array(CommandLine.arguments.dropFirst())

if args.isEmpty || args.contains("--help") || args.contains("-h") || args.contains("help") {
    printUsage()
    exit(0)
}

do {
    try run(args)
} catch {
    print("Error: \(error)")
    exit(1)
}

// MARK: - Command Processing

func run(_ args: [String]) throws {
    var outputName: String?
    var canvasSize = 256
    var backgroundColor: String?
    var gridWidth: Int?
    var gridHeight: Int?
    var layerSpecs: [(path: String, color: String, zIndex: Int)] = []

    var i = 0
    while i < args.count {
        let arg = args[i]

        switch arg {
        case "-o", "--output":
            guard i + 1 < args.count else {
                throw CLIError.missingValue(arg)
            }
            outputName = args[i + 1]
            i += 2

        case "-s", "--size":
            guard i + 1 < args.count, let size = Int(args[i + 1]) else {
                throw CLIError.invalidValue(arg, args.count > i + 1 ? args[i + 1] : "")
            }
            canvasSize = size
            i += 2

        case "-w", "--width":
            guard i + 1 < args.count, let w = Int(args[i + 1]) else {
                throw CLIError.invalidValue(arg, args.count > i + 1 ? args[i + 1] : "")
            }
            gridWidth = w
            i += 2

        case "-h", "--height":
            guard i + 1 < args.count, let h = Int(args[i + 1]) else {
                throw CLIError.invalidValue(arg, args.count > i + 1 ? args[i + 1] : "")
            }
            gridHeight = h
            i += 2

        case "--bg":
            guard i + 1 < args.count else {
                throw CLIError.missingValue(arg)
            }
            backgroundColor = args[i + 1]
            i += 2

        default:
            // Parse layer spec: path:color[:zIndex]
            if !arg.hasPrefix("-") {
                let spec = try parseLayerSpec(arg, index: layerSpecs.count)
                layerSpecs.append(spec)
            }
            i += 1
        }
    }

    guard let output = outputName else {
        throw CLIError.missingOutput
    }

    guard !layerSpecs.isEmpty else {
        throw CLIError.noLayers
    }

    // Auto-detect grid size if not specified
    let paths = layerSpecs.map(\.path)
    let bounds = try LayerMerger.combinedBounds(from: paths)
    let width = gridWidth ?? bounds.width
    let height = gridHeight ?? bounds.height

    guard width > 0, height > 0 else {
        throw CLIError.invalidBounds
    }

    // Load and merge layers
    let layers = try LayerMerger.loadLayers(from: layerSpecs)
    let grid = LayerMerger.merge(layers: layers, width: width, height: height)

    // Render SVG
    let config = SVGConfig(
        canvasWidth: canvasSize,
        canvasHeight: canvasSize,
        backgroundColor: backgroundColor
    )
    let svg = SVGRenderer.render(grid: grid, config: config)

    // Write SVG file
    let svgPath = "\(output).svg"
    try svg.write(toFile: svgPath, atomically: true, encoding: .utf8)
    print("Created: \(svgPath)")

    // Write JSON file
    let jsonPath = "\(output).json"
    let jsonData = try grid.toJSON()
    try jsonData.write(to: URL(fileURLWithPath: jsonPath))
    print("Created: \(jsonPath)")

    print()
    print("Grid: \(width)x\(height) pixels")
    print("Canvas: \(canvasSize)x\(canvasSize) px")
    print("Layers: \(layers.count)")
}

// MARK: - Layer Spec Parsing

func parseLayerSpec(_ spec: String, index: Int) throws -> (path: String, color: String, zIndex: Int) {
    let parts = spec.split(separator: ":", omittingEmptySubsequences: false).map(String.init)

    guard parts.count >= 2 else {
        throw CLIError.invalidLayerSpec(spec)
    }

    let path = parts[0]
    let color = parts[1].hasPrefix("#") ? parts[1] : "#\(parts[1])"

    // Validate file exists
    guard FileManager.default.fileExists(atPath: path) else {
        throw CLIError.fileNotFound(path)
    }

    let zIndex = parts.count > 2 ? (Int(parts[2]) ?? index) : index

    return (path, color, zIndex)
}

// MARK: - CLI Errors

enum CLIError: Error, CustomStringConvertible {
    case missingValue(String)
    case invalidValue(String, String)
    case missingOutput
    case noLayers
    case invalidLayerSpec(String)
    case fileNotFound(String)
    case invalidBounds

    var description: String {
        switch self {
        case .missingValue(let opt):
            return "Missing value for \(opt)"
        case .invalidValue(let opt, let val):
            return "Invalid value '\(val)' for \(opt)"
        case .missingOutput:
            return "Missing required --output <name>"
        case .noLayers:
            return "No layer files specified"
        case .invalidLayerSpec(let spec):
            return "Invalid layer spec '\(spec)'. Use: path:color[:zIndex]"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidBounds:
            return "Invalid grid bounds (empty files?)"
        }
    }
}

// MARK: - Usage

func printUsage() {
    print("""
    ascii-pixel-cli - ASCII to Pixel Art Converter

    USAGE:
      ascii-pixel-cli -o <name> [OPTIONS] <layer:color[:z]>...

    ARGUMENTS:
      <layer:color[:z]>     Layer file with color and optional z-index
                            Example: body.txt:#FF0000:1

    OPTIONS:
      -o, --output <name>   Output base name (creates .svg and .json)
      -s, --size <int>      Canvas size in pixels (default: 256)
      -w, --width <int>     Grid width (auto-detect if omitted)
      -h, --height <int>    Grid height (auto-detect if omitted)
      --bg <color>          Background color hex (default: transparent)
      --help                Show this help

    LAYER FORMAT:
      Fill chars: # * X @ O  (counted as pixels)
      Empty:      space . -  (transparent)

    EXAMPLES:
      # Single layer
      ascii-pixel-cli -o heart heart.txt:#FF0000

      # Multi-layer with z-order
      ascii-pixel-cli -o sprite \\
        bg.txt:#87CEEB:0 \\
        body.txt:#FFD800:1 \\
        outline.txt:#000000:2

      # Custom size with background
      ascii-pixel-cli -o icon -s 512 --bg "#1A1A2E" art.txt:#FFFFFF
    """)
}
