#!/usr/bin/env bash
# Native Android build (NDK r10e, armeabi-v7a, stlport_static) — matches handheld/project/android/jni.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
JNI_DIR="$ROOT/handheld/project/android/jni"

if [[ ! -f "$JNI_DIR/Application.mk" ]] || [[ ! -f "$JNI_DIR/Android.mk" ]]; then
  echo "error: expected jni tree at $JNI_DIR"
  exit 1
fi

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  echo "error: ANDROID_NDK_HOME is not set (point it at your NDK r10e root, e.g. .../android-ndk-r10e)"
  exit 1
fi

NDK_BUILD="$ANDROID_NDK_HOME/ndk-build"
if [[ ! -x "$NDK_BUILD" ]]; then
  echo "error: not executable: $NDK_BUILD"
  exit 1
fi

# RakNet is pulled in via $(call import-module, raknet/jni)
export NDK_MODULE_PATH="$ROOT/handheld/project/lib_projects"

NPROC="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)"

MODE="${1:-debug}"
case "$MODE" in
  debug)
    # NDK_DEBUG=1 keeps symbols; APP_OPTIM=debug matches a typical debug workflow.
    (cd "$JNI_DIR" && "$NDK_BUILD" -j"$NPROC" NDK_DEBUG=1 APP_OPTIM=debug V=1)
    ;;
  release)
    (cd "$JNI_DIR" && "$NDK_BUILD" -j"$NPROC" NDK_DEBUG=0 APP_OPTIM=release V=1)
    ;;
  *)
    echo "usage: $0 {debug|release}"
    exit 1
    ;;
esac

echo "ok: $MODE build finished (see handheld/project/android/libs and obj/)"
