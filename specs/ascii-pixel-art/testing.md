---
spec: ascii-pixel-art.spec.md
---

## Automated Testing

| Evidence | Requirements | What It Covers |
|----------|--------------|----------------|
| `ASCIIPixelArtTests.swift` parser suites | REQ-ascii-pixel-art-001 | Default/custom parsing, bounds, whitespace, Unicode, tabs, CRLF, and long lines. |
| `ASCIIPixelArtTests.swift` grid suites | REQ-ascii-pixel-art-002, REQ-ascii-pixel-art-003 | Bounds safety, row-major enumeration, JSON, Color bridging, clearing, and invalid hex. |
| `ASCIIPixelArtTests.swift` layer suites | REQ-ascii-pixel-art-004 | Z-index composition, stable equal ordering, empty/many layers, and invalid coordinates. |
| `ASCIIPixelArtTests.swift` SVG suites | REQ-ascii-pixel-art-005, REQ-ascii-pixel-art-006 | Documents, rectangles, configuration, backgrounds, scaling, and multiple pixels. |
| `ASCIIPixelArtTests.swift` integration suite | REQ-ascii-pixel-art-001, REQ-ascii-pixel-art-002, REQ-ascii-pixel-art-004, REQ-ascii-pixel-art-006 | Parse-to-grid-to-SVG and multi-layer flows. |
| `fledge lanes run verify` | REQ-ascii-pixel-art-008 | SwiftPM build and all 63 tests across 12 suites. |

## Manual Testing
- Review `main.swift` against REQ-ascii-pixel-art-007 and require exact-head hosted Trust/CodeQL.
- Confirm existing macOS, Ubuntu, and DocC workflows remain independently present.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Empty rows or trailing newline | Preserve row count in bounds and y coordinates. |
| Coordinate is outside the grid | Read nil and ignore writes or layer paint. |
| Equal layer z-index | Later input layer paints later. |
| Invalid stored hex | Preserve string; omit from typed Color results. |
| CLI layer lacks a file or color | Fail with a descriptive CLI error. |
