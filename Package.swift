// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SDOSEnvironment",
    platforms: [
       .iOS("8.0")
    ],
    products: [
        .executable(
            name: "SDOSEnvironmentScript",
            targets: ["SDOSEnvironmentScript"]),
        .library(
                name: "SDOSEnvironment",
                targets: ["SDOSEnvironment"])
    ],
    dependencies: [
        .package(url: "https://github.com/RNCryptor/RNCryptor.git", from:Version(stringLiteral: "5.1.0"))
    ],
    targets: [
        .target(
            name: "SDOSEnvironmentScript",
            dependencies: [
                "RNCryptor"
            ],
            path: "Sample/SDOSEnvironment/SDOSEnvironmentScript"),
        .target(
            name: "SDOSEnvironment",
            dependencies: [
                "RNCryptor"
            ],
            path: "src/Classes/Manager")
    ]
)
