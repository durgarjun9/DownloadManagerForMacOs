# DownloadManager For macOS

A high-performance, native macOS Download Manager with dual-engine support for HTTP/S and Torrent protocols.

## Features

- **Dual-Engine Support**:
  - **HTTP Engine**: Multi-threaded downloads with parallel segments (8+ threads) and dynamic segmentation.
  - **Torrent Engine**: Powered by `libtorrent-rasterbar`, supporting magnet links and `.torrent` files.
- **Performance**:
  - Direct disk pre-allocation.
  - Global speed limiter and priority toggles.
  - Optimized for high-speed fiber connections.
- **Modern UI**:
  - Translucent macOS sidebar interface using SwiftUI.
  - Real-time dashboard for active transfers and completion estimates.
  - Detailed settings for configuration.

## Requirements

- macOS 14+ (Sonoma or later)
- Xcode 15 or later
- Homebrew (to install dependencies)

## Setup & Build Instructions

### 1. Install Dependencies

You'll need `libtorrent-rasterbar` installed on your Mac:

```bash
brew install libtorrent-rasterbar
```

### 2. Build via Terminal

Navigate to the project directory and run:

```bash
cd DownloadManagerForMac
swift build
```

### 3. Run the Application

```bash
swift run DownloadManagerApp
```

## Implementation Details

- **SwiftUI**: Modern interface with `NavigationSplitView`.
- **C++/Swift Bridge**: A custom wrapper for `libtorrent` functionality.
- **Dynamic Segmentation**: HTTP downloads dynamically re-assign ranges to optimize speed.

## License
MIT
