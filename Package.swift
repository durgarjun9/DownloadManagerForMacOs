// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DownloadManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "DownloadManagerCore", targets: ["DownloadManagerCore"]),
        .executable(name: "DownloadManagerApp", targets: ["DownloadManagerApp"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LibTorrentWrapper",
            dependencies: [],
            path: "Sources/LibTorrentWrapper",
            cxxSettings: [
                .unsafeFlags(["-I/opt/homebrew/include"]),
                .define("BOOST_ASIO_HAS_STD_CHRONO")
            ],
            linkerSettings: [
                .linkedLibrary("torrent-rasterbar"),
                .unsafeFlags(["-L/opt/homebrew/lib"])
            ]
        ),
        .target(
            name: "DownloadManagerCore",
            dependencies: ["LibTorrentWrapper"],
            path: "Sources/DownloadManagerCore"
        ),
        .executableTarget(
            name: "DownloadManagerApp",
            dependencies: ["DownloadManagerCore"],
            path: "Sources/DownloadManagerApp",
            swiftSettings: [
                .define("SWIFTUI_APP")
            ]
        ),
        .testTarget(
            name: "DownloadManagerTests",
            dependencies: ["DownloadManagerCore"],
            path: "Tests/DownloadManagerTests"
        )
    ],
    cxxLanguageStandard: .cxx17
)
