#!/bin/bash

# Build StorageMenuApp and package it as a .app bundle plus DMG.
# Usage: ./scripts/package_dmg.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PRODUCT_NAME="StorageMenuApp"
CONFIGURATION="release"
DIST_DIR="$PROJECT_ROOT/dist"
APP_DIR="$DIST_DIR/${PRODUCT_NAME}.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
STAGING_DIR="$DIST_DIR/dmg-staging"
DMG_PATH="$DIST_DIR/${PRODUCT_NAME}.dmg"
ICON_SOURCE="$PROJECT_ROOT/Sources/Resources/AppIcon.icns"

echo "[1/5] Cleaning previous dist artifacts..."
rm -rf "$DIST_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$STAGING_DIR"

echo "[2/5] Building ${PRODUCT_NAME} (${CONFIGURATION})..."
swift build -c "$CONFIGURATION"
BIN_PATH="$(swift build -c "$CONFIGURATION" --show-bin-path)"
EXECUTABLE="$BIN_PATH/$PRODUCT_NAME"

if [[ ! -f "$EXECUTABLE" ]]; then
    echo "❌ Could not find built binary at $EXECUTABLE"
    exit 1
fi

echo "[3/5] Creating app bundle structure..."
cp "$EXECUTABLE" "$MACOS_DIR/$PRODUCT_NAME"
chmod +x "$MACOS_DIR/$PRODUCT_NAME"

if [[ -f "$ICON_SOURCE" ]]; then
    cp "$ICON_SOURCE" "$RESOURCES_DIR/AppIcon.icns"
else
    echo "⚠️  Warning: Icon file not found at $ICON_SOURCE"
fi

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>StorageMenuApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.StorageMenuApp</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>StorageMenuApp</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "[4/5] Staging bundle for DMG..."
cp -R "$APP_DIR" "$STAGING_DIR/"

echo "[5/5] Creating DMG at ${DMG_PATH}..."
hdiutil create \
    -volname "$PRODUCT_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov -format UDZO \
    "$DMG_PATH"

echo "✅ Done! DMG created at: ${DMG_PATH}"
