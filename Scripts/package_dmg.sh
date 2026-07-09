#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="0.0.6"
SCHEME="UpdatePilot"
PROJECT="UpdatePilot.xcodeproj"
CONFIGURATION="Release"
BUILD_ROOT="${BUILD_ROOT:-/Volumes/Externe Festplatte/Xcode/Build/UpdatePilot}"
DERIVED_DATA="${DERIVED_DATA:-/Volumes/Externe Festplatte/Xcode/DerivedData/UpdatePilot-package}"
DIST_DIR="$ROOT/dist"
APP_NAME="UpdatePilot.app"
DMG_NAME="UpdatePilot-$VERSION.dmg"
VOLUME_NAME="UpdatePilot $VERSION"

cd "$ROOT"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

xcodegen generate

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO

APP_SOURCE="$DERIVED_DATA/Build/Products/$CONFIGURATION/$APP_NAME"
if [[ ! -d "$APP_SOURCE" ]]; then
  echo "App bundle not found: $APP_SOURCE" >&2
  exit 1
fi

/usr/bin/ditto "$APP_SOURCE" "$DIST_DIR/$APP_NAME"

# Create a simple install folder with an Applications shortcut for the DMG.
DMG_STAGING="$BUILD_ROOT/dmg-staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"
/usr/bin/ditto "$DIST_DIR/$APP_NAME" "$DMG_STAGING/$APP_NAME"
ln -s /Applications "$DMG_STAGING/Applications"

rm -f "$DIST_DIR/$DMG_NAME"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  "$DIST_DIR/$DMG_NAME"

/usr/bin/du -h "$DIST_DIR/$DMG_NAME"
echo "Built $DIST_DIR/$APP_NAME"
echo "Built $DIST_DIR/$DMG_NAME"
