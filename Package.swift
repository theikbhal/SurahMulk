// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SurahMulk",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SurahMulk", targets: ["SurahMulk"])
    ],
    targets: [
        .executableTarget(
            name: "SurahMulk",
            path: "Sources/SurahMulk",
            resources: [.process("Resources")]
        )
    ]
)
