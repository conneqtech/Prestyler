// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Prestyler",
    products: [
        .library(
            name: "Prestyler",
            targets: ["Prestyler"]),
    ],
    targets: [
        .target(
            name: "Prestyler",
            dependencies: [],
            path: "Prestyler/Classes",
        )
    ],

    swiftLanguageVersions: [.v4]
)