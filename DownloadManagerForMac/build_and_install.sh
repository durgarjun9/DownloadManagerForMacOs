#!/bin/bash

# Exit on any error
set -e

APP_NAME="DownloadManager"
BUILD_PATH=".build/release/DownloadManagerApp"
BUNDLE_NAME="$APP_NAME.app"
INSTALL_PATH="/Applications/$BUNDLE_NAME"

echo "🚀 Starting build for $APP_NAME..."

# 1. Build the Swift Package in release mode
swift build -c release

# 2. Setup the App Bundle structure
echo "📦 Creating App Bundle structure..."
rm -rf "$BUNDLE_NAME"
mkdir -p "$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUNDLE_NAME/Contents/Resources"

# 3. Copy the binary
echo "📁 Copying binary..."
cp "$BUILD_PATH" "$BUNDLE_NAME/Contents/MacOS/$APP_NAME"

# 4. Generate Info.plist
echo "📝 Generating Info.plist..."
cat <<EOF > "$BUNDLE_NAME/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.downloadmanager.mac</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 5. Install to Applications folder
echo "🚚 Installing to /Applications..."
rm -rf "$INSTALL_PATH"
mv "$BUNDLE_NAME" /Applications/

echo "✅ Done! $APP_NAME is now installed in your Applications folder."
echo "💡 Reminder: If opening for the first time, Right-Click -> Open to bypass security warning."
