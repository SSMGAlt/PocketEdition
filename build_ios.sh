#!/usr/bin/env bash
# iOS build for CI/local: targets iphonesimulator with a host-matching arch (x86_64 or arm64).
# Overrides legacy project settings (iphoneos6.0 SDK, llvmgcc42) via xcodebuild flags — no .pbxproj edits.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$ROOT/handheld/project/iosproj/minecraftpe.xcodeproj"

if [[ ! -d "$PROJECT" ]]; then
  echo "error: missing Xcode project: $PROJECT"
  exit 1
fi

MODE="${1:-debug}"
case "$MODE" in
  debug)   CONFIGURATION="Debug" ;;
  release) CONFIGURATION="Release" ;;
  *)
    echo "usage: $0 {debug|release}"
    exit 1
    ;;
esac

HOST_ARCH="$(uname -m)"
case "$HOST_ARCH" in
  arm64)  SIM_ARCH="arm64" ;;
  x86_64) SIM_ARCH="x86_64" ;;
  *)
    echo "error: unsupported host architecture: $HOST_ARCH (need arm64 or x86_64)"
    exit 1
    ;;
esac

# Match legacy DerivedData layout (…/Build/Products/<Config>-iphonesimulator/) for CI artifact paths.
# Do not use -derivedDataPath without -scheme: Xcode 15+ errors with only -target (exit 64).
BUILD_IOS="$ROOT/build/ios"
mkdir -p "$BUILD_IOS/Build/Products" "$BUILD_IOS/Build/Intermediates.noindex"

# iphoneos6.0 + llvmgcc42 in the checked-in project are obsolete; -sdk iphonesimulator + Clang override below.
# Deployment target is raised only so the modern linker/clang accept the build (2013 game code remains unchanged).
exec xcodebuild \
  -project "$PROJECT" \
  -target minecraftpe \
  -configuration "$CONFIGURATION" \
  -sdk iphonesimulator \
  OBJROOT="$BUILD_IOS/Build/Intermediates.noindex" \
  SYMROOT="$BUILD_IOS/Build/Products" \
  IPHONEOS_DEPLOYMENT_TARGET=11.0 \
  VALID_ARCHS="$SIM_ARCH" \
  ARCHS="$SIM_ARCH" \
  ONLY_ACTIVE_ARCH=YES \
  GCC_VERSION=com.apple.compilers.llvm.clang.1_0 \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build
