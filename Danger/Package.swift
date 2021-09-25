// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DangerDependencies",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]), // dev
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.0.0"), // dev
        .package(name: "DangerXCodeSummary", url: "https://github.com/f-meloni/danger-swift-xcodesummary.git", from: "1.2.1"), // dev
        .package(name: "DangerSwiftCoverage", url: "https://github.com/f-meloni/danger-swift-coverage.git", from: "1.2.1"), // dev
        .package(name: "DangerSwiftHammer", url: "https://github.com/el-hoshino/DangerSwiftHammer.git", from: "0.1.1"), // dev
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "DangerDependencies", dependencies: ["danger-swift", "DangerXCodeSummary", "DangerSwiftCoverage", "DangerSwiftHammer"]), // dev
    ]
)
