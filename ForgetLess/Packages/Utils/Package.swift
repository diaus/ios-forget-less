// swift-tools-version: 6.2
import PackageDescription

// Zero warnings, matching the app's SWIFT_TREAT_WARNINGS_AS_ERRORS.
let zeroWarnings: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "Utils",
    // `.macOS` lets the tests run on the Mac with `swift test`; the app ships on iOS only.
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "Utils", targets: ["Utils"]),
    ],
    targets: [
        .target(name: "Utils", swiftSettings: zeroWarnings),
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"],
            swiftSettings: zeroWarnings
        ),
    ],
    // The Swift 6 language mode checks concurrency completely.
    swiftLanguageModes: [.v6]
)
