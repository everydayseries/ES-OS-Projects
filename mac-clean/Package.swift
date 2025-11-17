// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StorageMenuApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "StorageMenuApp",
            targets: ["StorageMenuApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "StorageMenuApp",
            path: "Sources",
            resources: [
                .copy("Resources/AppIcon.icns")
            ]
        )
    ]
)
