---
change: CHG-0002-document-the-existing-swift-ascii-library-and-cli-at-complete-specsync-coverage
artifact: testing
---

# Testing

| Requirements | Evidence |
|--------------|----------|
| `REQ-ascii-pixel-art-001` | Parser and parser-edge suites cover default/custom fills, bounds, whitespace, Unicode, tabs, CRLF, and long rows. |
| `REQ-ascii-pixel-art-002` | Grid and grid-edge suites cover storage, bounds, row-major ordering, overwrite, clear, and dimensions. |
| `REQ-ascii-pixel-art-003` | Grid JSON and Color suites cover Codable round trips, typed conversion, nil, and invalid hex. |
| `REQ-ascii-pixel-art-004` | Layer suites cover ordering, overlap, empty/many layers, defaults, and invalid coordinates; file behavior is source-reviewed. |
| `REQ-ascii-pixel-art-005` | SVG builder suite covers document attributes, content, rectangle geometry, fill, and self-closing syntax. |
| `REQ-ascii-pixel-art-006` | SVG renderer/config suites cover defaults, typed/string backgrounds, scaling, backgrounds, and pixels. |
| `REQ-ascii-pixel-art-007` | Source review covers every CLI option, layer-spec rule, validation error, bounds fallback, and dual-output write. |
| `REQ-ascii-pixel-art-008` | `fledge lanes run verify` builds both products and runs all 63 tests across 12 suites. |
