---
module: ascii-pixel-art
version: 3
status: active
files:
  - Sources/ASCIIPixelArt/ASCIIParser.swift
  - Sources/ASCIIPixelArt/LayerMerger.swift
  - Sources/ASCIIPixelArt/PixelGrid.swift
  - Sources/ASCIIPixelArt/SVGBuilder.swift
  - Sources/ASCIIPixelArt/SVGRenderer.swift
  - Sources/ascii-pixel-cli/main.swift
db_tables: []
depends_on: []
---

# ASCII Pixel Art

## Purpose

Swift ASCII converts newline-delimited character art into a sparse colored pixel grid, composes ordered layers, and renders deterministic SVG and JSON output. The package exposes the `ASCIIPixelArt` Swift library plus the `ascii-pixel-cli` executable. It owns parsing, bounds, grid storage, Color conversion, file-backed layers, SVG construction, CLI validation, and local output files. It does not own the input artwork, filesystem availability, downstream SVG consumers, or the external `swift-color` package.

## Public API

| Export | Contract |
|--------|----------|
| `ASCIIParser` | Namespace for character-art parsing and bounds calculation. |
| `defaultFillChars` | The filled-character set `#`, `*`, `X`, `@`, and `O`. |
| `parse` | Returns filled coordinates in row-major input order using the supplied character set. |
| `bounds` | Returns maximum character width and newline-preserving row count. |
| `PixelGrid` | Codable and Sendable rectangular grid backed by optional hex strings. |
| `width` | Immutable grid width. |
| `height` | Immutable grid height. |
| `pixels` | Publicly readable, privately set two-dimensional optional-string storage. |
| `init` | Public grid, layer, and SVG configuration construction. |
| `subscript` | Public bounds-safe two-dimensional grid access. |
| `filledPixels` | Returns stored non-nil strings in row-major order. |
| `toJSON` | Encodes the complete grid as pretty-printed, key-sorted JSON. |
| `setPixel` | Stores a `Color` hex value or clears the cell for nil. |
| `color` | Converts a stored valid hex string to `Color`, otherwise returns nil. |
| `coloredPixels` | Returns only stored strings that successfully convert to `Color`. |
| `Layer` | Sendable coordinate, color, and z-index value. |
| `pixels` | Coordinates painted by a layer. |
| `color` | Hex string stored for every painted coordinate. |
| `zIndex` | Painter-order key, defaulting to zero. |
| `LayerMerger` | Namespace for ordered composition and file-backed layer loading. |
| `merge` | Sorts low-to-high z-index and paints later layers over earlier layers. |
| `loadLayers` | Reads UTF-8 files, parses default fill characters, and preserves color/z-index metadata. |
| `combinedBounds` | Reads UTF-8 files and returns their maximum width and height. |
| `SVGBuilder` | Namespace for deterministic SVG document and rectangle strings. |
| `document` | Wraps content in an SVG element with dimensions and matching view box. |
| `rect` | Produces one self-closing rectangle with numeric geometry and fill. |
| `SVGConfig` | Sendable canvas dimensions and optional background hex string. |
| `canvasWidth` | Output SVG width. |
| `canvasHeight` | Output SVG height. |
| `backgroundColor` | Optional background hex string. |
| Default configuration | Transparent 256-by-256 configuration; initializers accept string-backed or typed Color backgrounds. |
| `SVGRenderer` | Namespace for rendering grids to complete SVG documents. |
| `render` | Scales each cell to the canvas, emits background first, then row-major filled pixels. |
| CLI executable | `ascii-pixel-cli` accepts output, canvas, optional grid/background settings and one or more `path:color[:z]` layers; it writes `.svg` and `.json`. |

## Invariants

1. Coordinates use a top-left origin with x increasing rightward and y increasing downward.
2. Parsing preserves empty rows, ignores characters outside the selected fill set, and reports the longest row as width.
3. Grid reads and writes are bounds-safe; filled values enumerate in row-major order.
4. Layer composition uses ascending z-index so higher values paint last; equal-index ordering remains input-stable.
5. File-backed layers use UTF-8 and the default fill-character set, while combined bounds take independent maxima.
6. SVG geometry divides canvas width by grid width and canvas height by grid height; an optional background rectangle precedes pixels.
7. The CLI requires an output base and at least one existing layer file, auto-detects omitted grid dimensions, and rejects non-positive final bounds.
8. Successful CLI execution writes both the SVG presentation and JSON grid using the same merged content.

## Behavioral Examples

### Scenario: Parse and render a single layer
- **Given** two rows containing four default fill characters
- **When** the text is parsed, merged into a two-by-two grid, and rendered on a 100-by-100 canvas
- **Then** four colored 50-by-50 rectangles appear in a complete SVG document

### Scenario: Compose overlapping layers
- **Given** two layers that paint the same coordinate at different z-index values
- **When** they are merged
- **Then** the higher-z-index color is stored at that coordinate

### Scenario: Convert through the CLI
- **Given** an existing UTF-8 layer file, a color, and an output base name
- **When** `ascii-pixel-cli` succeeds
- **Then** it auto-detects omitted bounds and writes matching `.svg` and `.json` files

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Grid coordinate is negative or outside dimensions | Read nil; ignore write. |
| Stored color string is invalid | Preserve the string; typed `Color` access omits it. |
| Layer coordinate is outside the target grid | Ignore it through bounds-safe grid assignment. |
| Layer or bounds file cannot be read as UTF-8 | Propagate the Foundation file error. |
| CLI option lacks a value | Throw a missing- or invalid-value CLI error. |
| CLI output or layer list is missing | Throw `missingOutput` or `noLayers`. |
| Layer spec has no color or its file is absent | Throw `invalidLayerSpec` or `fileNotFound`. |
| Effective grid width or height is non-positive | Throw `invalidBounds`. |

## Dependencies

| Module | Use |
|--------|-----|
| Foundation | File I/O, command-line arguments, JSON, strings, URLs, and process exit. |
| `swift-color` / `Color` | Optional typed color conversion and SVG background configuration. |
| Swift Package Manager | Library, executable, tests, and DocC plugin integration. |

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | `user:0xLeif` | Documented existing library and CLI behavior at complete coverage without product-code changes. |
| 2026-07-14 | CHG-0002-document-the-existing-swift-ascii-library-and-cli-at-complete-specsync-coverage: Document the existing Swift ASCII library and CLI at complete SpecSync coverage |
