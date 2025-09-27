// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ImageLoader",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ImageLoader",
            targets: ["ImageLoader"]
        )
    ],
    targets: [
        .target(
            name: "ImageLoader",
            dependencies: []
        ),
        .testTarget(
            name: "ImageLoaderTests",
            dependencies: ["ImageLoader"]
        )
    ]
)
