// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ASCIIPixelArtWASM",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ascii-pixel-wasm", targets: ["ASCIIPixelArtWASM"])
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/swiftwasm/carton", from: "1.1.0"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.21.0"),
    ],
    targets: [
        .executableTarget(
            name: "ASCIIPixelArtWASM",
            dependencies: [
                .product(name: "ASCIIPixelArt", package: "swift-ascii"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
            ]
        )
    ]
)
