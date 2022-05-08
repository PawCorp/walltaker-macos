// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "walltaker-test",
    dependencies: [
        .package(url: "https://github.com/dduan/Termbox.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "walltaker-test",
            dependencies: ["Termbox"]),
        .testTarget(
            name: "walltaker-testTests",
            dependencies: ["walltaker-test", "Termbox"]),
    ]
)
