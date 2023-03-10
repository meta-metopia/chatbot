// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "next-chatbot-server",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/sirily11/AzureTextToSpeech-Swift", branch: "main"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift"),
                .product(name: "AzureTextToSpeech", package: "AzureTextToSpeech-Swift"),
                .product(name: "SotoS3", package: "soto")
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [.target(name: "App")]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
