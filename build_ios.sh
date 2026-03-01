#!/usr/bin/env bash
#
# build_ios.sh - MCPE 2013 iOS build script (macOS only)
#
# Requires:
#   macOS with Xcode installed (xcodebuild must be available)
#   The Xcode project from the repo's iOS source directory
#
# Builds for the iOS Simulator by default. Building for a real device
# requires a paid Apple Developer account. See the notes at the bottom.
#
# Usage:
#   ./build_ios.sh [release|debug] [clean]
#

set -e

BUILD_TYPE="${1:-debug}"
DO_CLEAN="${2:-}"

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if ! command -v xcodebuild &>/dev/null; then
    echo "ERROR: xcodebuild not found. This script requires macOS with Xcode installed."
    echo "Install Xcode from the App Store, then run: xcode-select --install"
    exit 1
fi

XCPROJ=$(find "$REPO_ROOT" -name "*.xcodeproj" -not -path "*/.git/*" | head -1)

if [ -z "$XCPROJ" ]; then
    echo "ERROR: No .xcodeproj found under $REPO_ROOT"
    exit 1
fi

# Pull the first available scheme from the project
SCHEME=$(xcodebuild -list -project "$XCPROJ" 2>/dev/null \
    | awk '/Schemes:/{flag=1; next} flag && /^[[:space:]]/{gsub(/^[[:space:]]+/,""); print; exit}')

if [ -z "$SCHEME" ]; then
    echo "ERROR: Could not detect a scheme from $XCPROJ"
    echo "Run 'xcodebuild -list -project $XCPROJ' to see available schemes."
    exit 1
fi

BUILD_DIR="$REPO_ROOT/build/ios"

if [ "$BUILD_TYPE" = "release" ]; then
    CONFIGURATION="Release"
    DSYM_FLAG="DEBUG_INFORMATION_FORMAT=dwarf"
else
    CONFIGURATION="Debug"
    # dwarf-with-dsym produces a .dSYM bundle for crash symbolication
    DSYM_FLAG="DEBUG_INFORMATION_FORMAT=dwarf-with-dsym"
fi

if [ "$DO_CLEAN" = "clean" ]; then
    xcodebuild \
        -project "$XCPROJ" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -sdk iphonesimulator \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGNING_ALLOWED=NO \
        clean
    echo "Clean complete."
fi

echo "Xcode project : $XCPROJ"
echo "Scheme        : $SCHEME"
echo "Configuration : $CONFIGURATION"
echo "Output dir    : $BUILD_DIR"
echo ""

xcodebuild \
    -project "$XCPROJ" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk iphonesimulator \
    -arch x86_64 \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    "$DSYM_FLAG" \
    build

PRODUCTS_DIR="$BUILD_DIR/Build/Products/${CONFIGURATION}-iphonesimulator"

echo ""
echo "Build complete."
echo "Products: $PRODUCTS_DIR"
echo ""

find "$PRODUCTS_DIR" -name "*.app" -o -name "*.dSYM" 2>/dev/null | sort | while read -r f; do
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    echo "  [$SIZE]  $f"
done

#
# Building for a real iOS device (optional):
#
#   Requires a paid Apple Developer account with a provisioning profile.
#   Replace the xcodebuild call above with:
#
#   xcodebuild \
#     -project "$XCPROJ" \
#     -scheme "$SCHEME" \
#     -configuration "$CONFIGURATION" \
#     -sdk iphoneos \
#     -arch armv7 \
#     DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
#     CODE_SIGN_IDENTITY="iPhone Developer" \
#     build
#
#   armv7 is correct for 2013-era MCPE targeting iPhone 4/4S/5.
#
