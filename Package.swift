// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-ascii",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ASCIIPixelArt", targets: ["ASCIIPixelArt"]),
        .executable(name: "ascii-pixel-cli", targets: ["ascii-pixel-cli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CorvidLabs/swift-color.git", from: "0.1.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "ASCIIPixelArt",
            dependencies: [
                .product(name: "Color", package: "swift-color"),
            ]
        ),
        .executableTarget(
            name: "ascii-pixel-cli",
            dependencies: ["ASCIIPixelArt"]
        ),
        .testTarget(
            name: "ASCIIPixelArtTests",
            dependencies: ["ASCIIPixelArt"]
        ),
    ]
)
