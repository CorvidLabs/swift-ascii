# ASCII Pixel Art semantic delta

## ADDED

### REQUIREMENT REQ-ascii-pixel-art-001
The parser SHALL return row-major coordinates for selected fill characters and calculate maximum-width, newline-preserving bounds.

Acceptance Criteria
- Default/custom fill sets, empty input/rows, Unicode, tabs, CRLF, long rows, and leading/trailing newlines retain current behavior.

### REQUIREMENT REQ-ascii-pixel-art-002
`PixelGrid` SHALL create transparent rectangular storage, expose bounds-safe read/write access, and enumerate non-nil strings in row-major order.

Acceptance Criteria
- Invalid coordinates read nil and ignore writes; overwrite, clear, square, non-square, single, and large grids retain behavior.

### REQUIREMENT REQ-ascii-pixel-art-003
`PixelGrid` SHALL round-trip Codable JSON and bridge stored hex strings to optional `Color` values without discarding invalid stored strings.

Acceptance Criteria
- JSON preserves dimensions/cells; nil clears; valid colors convert; invalid hex remains string-backed and is omitted from typed results.

### REQUIREMENT REQ-ascii-pixel-art-004
Layers SHALL preserve coordinates/color/z-index, compose from low to high z-index, and load or measure UTF-8 character-art files.

Acceptance Criteria
- Higher z-index wins, equal-index input order is stable, invalid grid coordinates are ignored, and file failures propagate.

### REQUIREMENT REQ-ascii-pixel-art-005
`SVGBuilder` SHALL produce a complete dimensioned SVG document and self-closing rectangle elements with caller-supplied geometry and fill.

Acceptance Criteria
- Namespace, width, height, view box, content, geometry, fill, and closing syntax remain deterministic.

### REQUIREMENT REQ-ascii-pixel-art-006
`SVGRenderer` SHALL scale grid cells independently to configured canvas dimensions, emit an optional background first, and render filled pixels in row-major order.

Acceptance Criteria
- Default/string/Color configuration, transparent backgrounds, non-square grids, large canvases, and multiple colors retain behavior.

### REQUIREMENT REQ-ascii-pixel-art-007
The CLI SHALL parse output, canvas, grid, background, and `path:color[:z]` arguments, validate required values/files/bounds, and write matching SVG and JSON outputs.

Acceptance Criteria
- Omitted z-index defaults to layer order; colors gain a leading `#`; omitted dimensions use combined bounds; failures exit nonzero with descriptive errors.

### REQUIREMENT REQ-ascii-pixel-art-008
Verification SHALL preserve the library and executable products, Swift 6/macOS 14 package contract, 63-test suite, macOS and Swift 6.0 Ubuntu CI, and independent DocC Pages publication.

Acceptance Criteria
- Native build/tests and exact-head Trust pass; `Sources/` and `Tests/` remain unchanged.
