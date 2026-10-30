// swift-tools-version: 6.2
import PackageDescription

// Zero warnings, matching the app's SWIFT_TREAT_WARNINGS_AS_ERRORS.
let zeroWarnings: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "Domain",
    // `.macOS` lets the tests run on the Mac with `swift test`; the app ships on iOS only.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    dependencies: [
        .package(path: "../Utils"),
    ],
    targets: [
        .target(name: "Domain", dependencies: ["Utils"], swiftSettings: zeroWarnings),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            swiftSettings: zeroWarnings
        ),
    ],
    // The Swift 6 language mode checks concurrency completely.
    swiftLanguageModes: [.v6]
)
