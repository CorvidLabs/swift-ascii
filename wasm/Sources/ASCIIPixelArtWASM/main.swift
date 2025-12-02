import JavaScriptKit
import ASCIIPixelArt

// Get the global JavaScript object
let document = JSObject.global.document
let window = JSObject.global

// Export functions to JavaScript
let asciiToSVG = JSClosure { arguments -> JSValue in
    guard arguments.count >= 1,
          let asciiText = arguments[0].string else {
        return .string("Error: ASCII text required")
    }

    let color = arguments.count > 1 ? arguments[1].string ?? "#000000" : "#000000"
    let size = arguments.count > 2 ? Int(arguments[2].number ?? 256) : 256

    // Parse ASCII to coordinates
    let pixels = ASCIIParser.parse(asciiText)
    let bounds = ASCIIParser.bounds(of: asciiText)

    guard bounds.width > 0, bounds.height > 0 else {
        return .string("Error: Empty ASCII art")
    }

    // Create grid and fill pixels
    var grid = PixelGrid(width: bounds.width, height: bounds.height)
    for (x, y) in pixels {
        grid[x, y] = color
    }

    // Render to SVG
    let config = SVGConfig(
        canvasWidth: size,
        canvasHeight: size,
        backgroundColor: nil
    )
    let svg = SVGRenderer.render(grid: grid, config: config)

    return .string(svg)
}

let parseASCIIToJSON = JSClosure { arguments -> JSValue in
    guard arguments.count >= 1,
          let asciiText = arguments[0].string else {
        return .string("Error: ASCII text required")
    }

    let color = arguments.count > 1 ? arguments[1].string ?? "#000000" : "#000000"

    // Parse ASCII to coordinates
    let pixels = ASCIIParser.parse(asciiText)
    let bounds = ASCIIParser.bounds(of: asciiText)

    guard bounds.width > 0, bounds.height > 0 else {
        return .string("{\"error\": \"Empty ASCII art\"}")
    }

    // Create grid and fill pixels
    var grid = PixelGrid(width: bounds.width, height: bounds.height)
    for (x, y) in pixels {
        grid[x, y] = color
    }

    // Convert to JSON
    do {
        let jsonData = try grid.toJSON()
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return .string(jsonString)
        }
        return .string("{\"error\": \"JSON encoding failed\"}")
    } catch {
        return .string("{\"error\": \"\(error)\"}")
    }
}

let mergeLayersToSVG = JSClosure { arguments -> JSValue in
    guard arguments.count >= 1,
          let layersArray = arguments[0].array else {
        return .string("Error: Layers array required")
    }

    let size = arguments.count > 1 ? Int(arguments[1].number ?? 256) : 256
    let bgColor = arguments.count > 2 ? arguments[2].string : nil

    var layers: [Layer] = []
    var maxWidth = 0
    var maxHeight = 0

    for index in 0..<layersArray.length {
        let layerObj = layersArray[index]
        guard let ascii = layerObj.ascii.string,
              let color = layerObj.color.string else {
            continue
        }

        let zIndex = Int(layerObj.zIndex.number ?? Double(index))
        let pixels = ASCIIParser.parse(ascii)
        let bounds = ASCIIParser.bounds(of: ascii)

        maxWidth = max(maxWidth, bounds.width)
        maxHeight = max(maxHeight, bounds.height)

        layers.append(Layer(pixels: pixels, color: color, zIndex: zIndex))
    }

    guard maxWidth > 0, maxHeight > 0 else {
        return .string("Error: No valid layers")
    }

    // Merge layers
    let grid = LayerMerger.merge(layers: layers, width: maxWidth, height: maxHeight)

    // Render to SVG
    let config = SVGConfig(
        canvasWidth: size,
        canvasHeight: size,
        backgroundColor: bgColor
    )
    let svg = SVGRenderer.render(grid: grid, config: config)

    return .string(svg)
}

// Expose functions on the window object
let asciiPixelArt = JSObject.global.Object.function!.new()
asciiPixelArt.asciiToSVG = asciiToSVG.jsValue
asciiPixelArt.parseToJSON = parseASCIIToJSON.jsValue
asciiPixelArt.mergeLayers = mergeLayersToSVG.jsValue
window.ASCIIPixelArt = asciiPixelArt.jsValue

// Log that we're ready
_ = JSObject.global.console.log("ASCIIPixelArt WASM module loaded!")
