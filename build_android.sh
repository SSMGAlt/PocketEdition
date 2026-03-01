#!/usr/bin/env bash
#
# build_android.sh - MCPE 2013 Android native build
#
# Required toolchain (this source cannot build with anything newer):
#   NDK r10e  - last NDK release with GCC and stlport. r17 dropped GCC,
#               r18 dropped stlport_static entirely.
#   GCC 4.8   - set via NDK_TOOLCHAIN_VERSION in Application.mk
#   stlport_static - the STL this source links against, set via APP_STL
#   android-8 - Android 2.2, the original minimum platform
#   armeabi-v7a - the original target ABI
#
# NDK r10e downloads:
#   Linux:  https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.bin
#   macOS:  https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.bin
#
# Usage:
#   ./build_android.sh [release|debug] [clean]
#

set -e

BUILD_TYPE="${1:-debug}"
DO_CLEAN="${2:-}"

NDK_PATH="${ANDROID_NDK_HOME:-${NDK_HOME:-${HOME}/android-ndk-r10e}}"
NDK_BUILD="$NDK_PATH/ndk-build"

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
HANDHELD_DIR="$REPO_ROOT/handheld"
JNI_DIR="$HANDHELD_DIR/jni"

if [ ! -d "$NDK_PATH" ]; then
    echo "ERROR: NDK r10e not found at: $NDK_PATH"
    echo ""
    echo "Set ANDROID_NDK_HOME or install to ~/android-ndk-r10e"
    echo "Linux: https://dl.google.com/android/repository/android-ndk-r10e-linux-x86_64.bin"
    echo "macOS: https://dl.google.com/android/repository/android-ndk-r10e-darwin-x86_64.bin"
    exit 1
fi

if [ ! -f "$NDK_BUILD" ]; then
    echo "ERROR: ndk-build not found at: $NDK_BUILD"
    exit 1
fi

if [ ! -f "$JNI_DIR/Android.mk" ]; then
    echo "ERROR: Android.mk not found at: $JNI_DIR/Android.mk"
    exit 1
fi

if command -v nproc &>/dev/null; then
    JOBS="$(nproc)"
elif command -v sysctl &>/dev/null; then
    JOBS="$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"
else
    JOBS=4
fi

if [ "$DO_CLEAN" = "clean" ]; then
    "$NDK_BUILD" -C "$HANDHELD_DIR" clean \
        NDK_PROJECT_PATH="$HANDHELD_DIR" \
        APP_BUILD_SCRIPT="$JNI_DIR/Android.mk"
    rm -rf "$HANDHELD_DIR/libs" "$HANDHELD_DIR/obj"
    echo "Clean complete."
fi

NDK_FLAGS=(
    -C "$HANDHELD_DIR"
    -j"$JOBS"
    NDK_PROJECT_PATH="$HANDHELD_DIR"
    APP_BUILD_SCRIPT="$JNI_DIR/Android.mk"
    NDK_OUT="$HANDHELD_DIR/obj"
    NDK_LIBS_OUT="$HANDHELD_DIR/libs"
)

if [ "$BUILD_TYPE" = "release" ]; then
    NDK_FLAGS+=(NDK_DEBUG=0 APP_OPTIM=release)
else
    # NDK_DEBUG=1 tells ndk-build to keep debug symbols in obj/ unstripped
    NDK_FLAGS+=(NDK_DEBUG=1 APP_OPTIM=debug)
fi

echo "Build type : $BUILD_TYPE"
echo "NDK path   : $NDK_PATH"
echo "JNI dir    : $JNI_DIR"
echo ""

"$NDK_BUILD" "${NDK_FLAGS[@]}"

echo ""
echo "Stripped libs (APK-ready) : $HANDHELD_DIR/libs/"
echo "Unstripped libs (symbols) : $HANDHELD_DIR/obj/"
echo ""

find "$HANDHELD_DIR/libs" -name "*.so" 2>/dev/null | sort | while read -r f; do
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    echo "  [$SIZE]  $f"
done
