#!/bin/bash

# Define variables
APP_NAME="DownloadManager"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "🚀 Building $APP_NAME for macOS..."

# 1. Compile the code using SPM
swift build -c release --arch arm64 --arch x86_64

# 2. Create the .app bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# 3. Copy the executable
cp ".build/apple/Products/Release/$APP_NAME" "$MACOS/"

# 4. Create a basic Info.plist
cat <<EOF > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.ai.downloadmanager</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
EOF

echo "✅ App bundle created: $APP_BUNDLE"
echo "👉 Run it with: open $APP_BUNDLE"
