---
spec: ascii-pixel-art.spec.md
---

## Key Decisions
- Preserve the library/CLI split, row-major and painter-order semantics, Swift 6 package surface, and `swift-color` integration.
- Keep macOS, Swift 6.0 Ubuntu, and DocC Pages workflows independent from the unified Trust gate.

## Files to Read First
- `ASCIIParser.swift`, `PixelGrid.swift`, `LayerMerger.swift`, `SVGRenderer.swift`, `main.swift`, and `ASCIIPixelArtTests.swift`.

## Current Status
The implementation contains five library files, one CLI file, and 63 deterministic tests across 12 suites. This migration changes governance and documentation only.

## Notes
CLI behavior has no separate process-level test suite; library parsing, grid, composition, SVG, edge cases, and end-to-end library flow are covered by the existing Swift Testing suite.
