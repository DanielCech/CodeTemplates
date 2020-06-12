// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Arena-Playground",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Arena-Playground",
            targets: ["Arena-Playground"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Arena-Playground",
            dependencies: []),
        .testTarget(
            name: "Arena-PlaygroundTests",
            dependencies: ["Arena-Playground"]),
    ]
)

package.dependencies = [
    .package(name: "Stencil", url: "https://github.com/stencilproject/Stencil", from: "0.13.0"),
    .package(name: "ScriptToolkit", url: "https://github.com/DanielCech/ScriptToolkit", .branch("master")),
    .package(name: "Files", url: "https://github.com/JohnSundell/Files", from: "4.1.1"),
    .package(name: "FileSmith", url: "https://github.com/kareman/FileSmith", from: "0.2.2"),
    .package(name: "Moderator", url: "https://github.com/kareman/Moderator", from: "0.5.1"),
    .package(name: "SwiftShell", url: "https://github.com/kareman/SwiftShell", from: "5.0.1")
]
package.targets = [
    .target(name: "Arena-Playground",
        dependencies: [
            .product(name: "Stencil", package: "Stencil"),
.product(name: "ScriptToolkit", package: "ScriptToolkit"),
.product(name: "Files", package: "Files"),
.product(name: "FileSmith", package: "FileSmith"),
.product(name: "Moderator", package: "Moderator"),
.product(name: "SwiftShell", package: "SwiftShell")
        ]
    )
]