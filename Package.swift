// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Nota4",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "Nota4",
            targets: ["Nota4"]
        )
    ],
    dependencies: [
        // TCA 1.11+
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.11.0"
        ),
        // GRDB 6.0+
        .package(
            url: "https://github.com/groue/GRDB.swift",
            from: "6.0.0"
        ),
        // MarkdownUI 2.0+
        .package(
            url: "https://github.com/gonzalezreal/swift-markdown-ui",
            from: "2.0.0"
        ),
        // Yams 5.0+
        .package(
            url: "https://github.com/jpsim/Yams",
            from: "5.0.0"
        ),
        // Ink 0.6+
        .package(
            url: "https://github.com/JohnSundell/Ink.git",
            from: "0.6.0"
        ),
        // Splash 0.16+
        .package(
            url: "https://github.com/JohnSundell/Splash.git",
            from: "0.16.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "Nota4",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Ink", package: "Ink"),
                .product(name: "Splash", package: "Splash"),
            ],
            path: "Nota4",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "Nota4Tests",
            dependencies: ["Nota4"],
            path: "Nota4Tests"
        ),
    ]
)

