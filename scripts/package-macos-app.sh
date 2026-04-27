#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-Bloom & Become}"
BUNDLE_ID="${BUNDLE_ID:-com.maskedsyntax.bloom-and-become}"
SOURCE_ICON="${SOURCE_ICON:-assets/sprites/logo.png}"
DIST_DIR="${DIST_DIR:-dist/macos}"
BUILD_DIR="${BUILD_DIR:-build/macos}"
LOVE_APP="${1:-${LOVE_APP:-/Applications/love.app}}"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "error: xcrun is required. Install Xcode or Xcode Command Line Tools." >&2
  exit 1
fi

if ! xcrun --find actool >/dev/null 2>&1; then
  echo "error: actool is required. Install full Xcode and select it with xcode-select." >&2
  exit 1
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "error: ruby is required and is normally included with macOS." >&2
  exit 1
fi

if [[ ! -f "$SOURCE_ICON" ]]; then
  echo "error: source icon not found: $SOURCE_ICON" >&2
  exit 1
fi

if [[ ! -d "$LOVE_APP" ]]; then
  echo "error: LÖVE app template not found: $LOVE_APP" >&2
  echo "usage: scripts/package-macos-app.sh /path/to/love.app" >&2
  exit 1
fi

APP_PATH="$DIST_DIR/$APP_NAME.app"
LOVE_FILE="$BUILD_DIR/game.love"
ASSET_CATALOG="$BUILD_DIR/Assets.xcassets"
APP_ICON_SET="$ASSET_CATALOG/AppIcon.appiconset"
ASSET_COMPILE_DIR="$BUILD_DIR/CompiledAssets"
PARTIAL_INFO="$BUILD_DIR/asset-info.plist"
LEGACY_ICON="$BUILD_DIR/AppIcon.icns"

rm -rf "$APP_PATH" "$BUILD_DIR"
mkdir -p "$DIST_DIR" "$BUILD_DIR" "$APP_ICON_SET" "$ASSET_COMPILE_DIR"

zip -9 -r "$LOVE_FILE" . \
  -x ".git/*" \
  -x "build/*" \
  -x "dist/*" \
  -x "*.app/*" \
  -x ".DS_Store" \
  -x "game.love" >/dev/null

make_icon() {
  local size="$1"
  local filename="$2"
  sips -s format png -z "$size" "$size" "$SOURCE_ICON" --out "$APP_ICON_SET/$filename" >/dev/null
}

make_icon 16 "icon_16x16.png"
make_icon 32 "icon_16x16@2x.png"
make_icon 32 "icon_32x32.png"
make_icon 64 "icon_32x32@2x.png"
make_icon 128 "icon_128x128.png"
make_icon 256 "icon_128x128@2x.png"
make_icon 256 "icon_256x256.png"
make_icon 512 "icon_256x256@2x.png"
make_icon 512 "icon_512x512.png"
make_icon 1024 "icon_512x512@2x.png"

cat > "$APP_ICON_SET/Contents.json" <<'JSON'
{
  "images": [
    { "idiom": "mac", "size": "16x16", "scale": "1x", "filename": "icon_16x16.png" },
    { "idiom": "mac", "size": "16x16", "scale": "2x", "filename": "icon_16x16@2x.png" },
    { "idiom": "mac", "size": "32x32", "scale": "1x", "filename": "icon_32x32.png" },
    { "idiom": "mac", "size": "32x32", "scale": "2x", "filename": "icon_32x32@2x.png" },
    { "idiom": "mac", "size": "128x128", "scale": "1x", "filename": "icon_128x128.png" },
    { "idiom": "mac", "size": "128x128", "scale": "2x", "filename": "icon_128x128@2x.png" },
    { "idiom": "mac", "size": "256x256", "scale": "1x", "filename": "icon_256x256.png" },
    { "idiom": "mac", "size": "256x256", "scale": "2x", "filename": "icon_256x256@2x.png" },
    { "idiom": "mac", "size": "512x512", "scale": "1x", "filename": "icon_512x512.png" },
    { "idiom": "mac", "size": "512x512", "scale": "2x", "filename": "icon_512x512@2x.png" }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
JSON

xcrun actool "$ASSET_CATALOG" \
  --compile "$ASSET_COMPILE_DIR" \
  --platform macosx \
  --minimum-deployment-target 11.0 \
  --app-icon AppIcon \
  --output-partial-info-plist "$PARTIAL_INFO" >/dev/null

ruby - "$APP_ICON_SET" "$LEGACY_ICON" <<'RUBY'
dir, output = ARGV
entries = {
  "icp4" => "icon_16x16.png",
  "icp5" => "icon_32x32.png",
  "icp6" => "icon_32x32@2x.png",
  "ic07" => "icon_128x128.png",
  "ic08" => "icon_256x256.png",
  "ic09" => "icon_512x512.png",
  "ic10" => "icon_512x512@2x.png",
  "ic11" => "icon_16x16@2x.png",
  "ic12" => "icon_32x32@2x.png",
  "ic13" => "icon_128x128@2x.png",
  "ic14" => "icon_256x256@2x.png",
}

chunks = entries.map do |type, filename|
  data = File.binread(File.join(dir, filename))
  [[type, data.bytesize + 8].pack("A4N"), data]
end

File.open(output, "wb") do |file|
  total_size = 8 + chunks.sum { |header, data| header.bytesize + data.bytesize }
  file.write(["icns", total_size].pack("A4N"))
  chunks.each { |header, data| file.write(header); file.write(data) }
end
RUBY

cp -R "$LOVE_APP" "$APP_PATH"
cp "$LOVE_FILE" "$APP_PATH/Contents/Resources/$APP_NAME.love"
cp "$ASSET_COMPILE_DIR/Assets.car" "$APP_PATH/Contents/Resources/Assets.car"
cp "$LEGACY_ICON" "$APP_PATH/Contents/Resources/AppIcon.icns"
cp "$LEGACY_ICON" "$APP_PATH/Contents/Resources/OS X AppIcon.icns"
cp "$LEGACY_ICON" "$APP_PATH/Contents/Resources/GameIcon.icns"

INFO_PLIST="$APP_PATH/Contents/Info.plist"
plutil -replace CFBundleName -string "$APP_NAME" "$INFO_PLIST"
plutil -replace CFBundleDisplayName -string "$APP_NAME" "$INFO_PLIST"
plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$INFO_PLIST"
plutil -replace CFBundleIconName -string "AppIcon" "$INFO_PLIST"
plutil -replace CFBundleIconFile -string "AppIcon" "$INFO_PLIST"

codesign --force --deep --sign - "$APP_PATH" >/dev/null 2>&1 || {
  echo "warning: ad-hoc codesign failed; continuing with the unsigned local app bundle" >&2
}

echo "Built $APP_PATH"
