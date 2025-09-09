// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "ZHKLine",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ZHKLine",
            targets: ["ZHKLine"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZHKLine",
            dependencies: [],
            path: "ZHKLine/Class",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "ZHKLineTests",
            dependencies: ["ZHKLine"],
            path: "ZHKLineTests"
        ),
    ]
)
