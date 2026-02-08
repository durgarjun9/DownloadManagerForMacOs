# DownloadManagerForMac

A high-performance, native macOS Download Manager with dual-engine support for HTTP/S and Torrents.

## 🚀 Features
- **MT-HTTPEngine**: Multi-threaded segmented downloading using URLSession Range headers.
- **Torrent Engine**: libtorrent-rasterbar integration for .torrent and magnet links.
- **SSD Optimization**: Direct disk pre-allocation and Zero-Copy I/O concepts.
- **Modern UI**: Translucent macOS sidebar, interactive dashboard, and glassmorphism stats.

---

## 🛠 Building the App

### Option 1: Terminal (Recommended)
You can build and run the app directly from your terminal using the Swift Package Manager.

**Quick Run:**
```bash
swift run
```

**Build a Native .app Bundle:**
We've included a helper script to package the app for you.
```bash
./build.sh
open DownloadManager.app
```

### Option 2: Xcode
1. Open **Xcode** and select "Create a new Xcode project" -> **macOS App**.
2. Drag the `Core/`, `Engines/`, `Models/`, and `UI/` folders into your project.
3. In **Signing & Capabilities**, enable:
   - **Network**: Incoming/Outgoing connections.
   - **File Access**: Downloads Folder (Read/Write).
4. Press `Cmd + R` to build and run.

---

## ⚙️ Development & Git

### Initialize Git
To track your changes:
```bash
git init
git add .
git commit -m "Initial commit: DownloadManager architecture"
```

### Project Structure
- `Core/`: Download orchestrator and disk performance logic.
- `Engines/`: HTTP and Torrent transfer engines.
- `Models/`: Shared data structures and Codable states.
- `UI/`: Native SwiftUI views and components.

---

## 📦 Prerequisites
- macOS Sonoma (14.0+)
- Xcode 15.0+ or Swift 5.9 toolchain
- (Optional) `brew install libtorrent-rasterbar` for full BitTorrent support.
