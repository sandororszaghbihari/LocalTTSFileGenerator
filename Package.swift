// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LocalTTSFileGenerator",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LocalTTSFileGenerator",
            targets: ["LocalTTSFileGenerator"]
        )
    ],
    targets: [
        .target(
            name: "LocalTTSFileGenerator"
        )
    ]
)
