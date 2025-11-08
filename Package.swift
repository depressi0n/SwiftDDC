// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftDDC",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftDDC",
            targets: ["SwiftDDC"]
        ),
        .executable(
            name: "ddc",
            targets: ["ddc"]
        ),
        .executable(
            name: "DDCMenu",
            targets: ["DDCMenu"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftDDC",
            dependencies: [],
            path: "Sources/SwiftDDC",
            linkerSettings: [
                .linkedFramework("CoreDisplay", .when(platforms: [.macOS]))
            ]
        ),
        .executableTarget(
            name: "ddc",
            dependencies: [
                "SwiftDDC",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/ddc"
        ),
        .executableTarget(
            name: "DDCMenu",
            dependencies: ["SwiftDDC"],
            path: "Sources/DDCMenu"
        ),
        .testTarget(
            name: "SwiftDDCTests",
            dependencies: ["SwiftDDC"])
    ]
)