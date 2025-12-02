// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-ascii",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ASCIIPixelArt", targets: ["ASCIIPixelArt"]),
        .executable(name: "ascii-pixel-cli", targets: ["ascii-pixel-cli"]),
    ],
    targets: [
        .target(
            name: "ASCIIPixelArt",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "ascii-pixel-cli",
            dependencies: ["ASCIIPixelArt"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ASCIIPixelArtTests",
            dependencies: ["ASCIIPixelArt"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
