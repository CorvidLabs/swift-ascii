# Changelog

All notable changes to swift-ascii will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-01

### Added

- `ASCIIParser` for parsing ASCII art text into pixel coordinates
- `PixelGrid` for 2D grid representation with sparse pixel storage
- `Layer` and `LayerMerger` for multi-layer composition with z-index ordering
- `SVGRenderer` and `SVGConfig` for SVG output generation
- `SVGBuilder` for low-level SVG element creation
- `ascii-pixel-cli` command-line tool for batch processing
- Color type integration via swift-color package
- JSON export for raw pixel grid data
- Swift 6 concurrency support with Sendable conformance

[0.1.0]: https://github.com/CorvidLabs/swift-ascii/releases/tag/0.1.0
