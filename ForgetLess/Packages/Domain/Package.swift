// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Domain",
    // `.macOS` lets the tests run on the Mac with `swift test`; the app ships on iOS only.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]
        ),
    ],
    // The Swift 6 language mode checks concurrency completely.
    swiftLanguageModes: [.v6]
)
