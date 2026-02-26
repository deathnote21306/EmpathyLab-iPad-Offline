// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EmpathyLab",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .executable(
            name: "EmpathyLabApp",
            targets: ["EmpathyLabApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "EmpathyLabApp",
            dependencies: [],
            path: "Sources/EmpathyLabApp",
            resources: [
                .process("../../Resources")
            ]
        )
    ]
)
