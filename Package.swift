// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DownloadManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DownloadManager", targets: ["DownloadManager"])
    ],
    targets: [
        .executableTarget(
            name: "DownloadManager",
            path: ".",
            exclude: ["README.md", "MasterPrompt.md", "build.sh"],
            sources: [
                "DownloadManagerApp.swift",
                "Core",
                "Engines",
                "Models",
                "UI"
            ]
        )
    ]
)
