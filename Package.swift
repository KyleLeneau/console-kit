// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Console",
    products: [
        .library(name: "Console", targets: ["Console"]),
        .library(name: "Command", targets: ["Command"]),
        .library(name: "LoggingKit", targets: ["LoggingKit"]),
    ],
    dependencies: [
        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package(url: "https://github.com/vapor/core.git", from: "3.0.0"),

        // 📦 Dependency injection / inversion of control framework.
        .package(url: "https://github.com/vapor/service.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Console", dependencies: ["Core", "COperatingSystem", "LoggingKit", "Service"]),
        .target(name: "Command", dependencies: ["Console"]),
        .testTarget(name: "ConsoleTests", dependencies: ["Console"]),
        .testTarget(name: "CommandTests", dependencies: ["Command"]),
        .target(name: "LoggingKit", dependencies: ["Core"]),
        .target(name: "ConsoleDevelopment", dependencies: ["Command", "Console", "LoggingKit"]),
    ]
)
