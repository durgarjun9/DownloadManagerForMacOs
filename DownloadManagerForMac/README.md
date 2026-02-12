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

### 3. Native Installation (Recommended)

To install the application into your `/Applications` folder, run the following automated build and bundle script:

```bash
# Build in Release mode
swift build -c release

# Create the App Bundle structure
APP_NAME="DownloadManager"
BUILD_PATH=".build/release/DownloadManagerApp"

mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

# Copy binary to bundle
cp "$BUILD_PATH" "$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Generate Info.plist
cat <<EOF > "$APP_NAME.app/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>\$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.downloadmanager.mac</string>
    <key>CFBundleName</key>
    <string>\$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Move to Applications folder
rm -rf /Applications/DownloadManager.app
mv DownloadManager.app /Applications/
```

### 4. Running the Application

- **Via Terminal**: `swift run DownloadManagerApp`
- **Via Applications**: Open `DownloadManager` from your Applications folder or Spotlight.
  - *Note: On first launch, right-click the app in Applications and select "Open" to bypass the unidentified developer warning.*

## Implementation Details

- **SwiftUI**: Modern interface with `NavigationSplitView`.
- **C++/Swift Bridge**: A custom wrapper for `libtorrent` functionality.
- **Dynamic Segmentation**: HTTP downloads dynamically re-assign ranges to optimize speed.

## License
MIT
