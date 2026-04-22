#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="/Volumes/SSDFajri/DEV/Projects/try_out"
FLUTTER_BIN="/Volumes/SSDFajri/DEV/SDKs/flutter/bin/flutter"
ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home}"
DEFAULT_DEVICE_ID="10DG3G0BJC000U7"

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
export JAVA_HOME="$JAVA_HOME"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:/Volumes/SSDFajri/DEV/SDKs/flutter/bin:$PATH"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb tidak ditemukan di PATH. Pastikan Android SDK terpasang di: $ANDROID_SDK_ROOT"
  exit 1
fi

usage() {
  cat <<'EOF'
Usage:
  scripts/android_dev.sh run [device_id]
  scripts/android_dev.sh attach [device_id]
  scripts/android_dev.sh logs [device_id]
  scripts/android_dev.sh doctor
  scripts/android_dev.sh devices

Notes:
- Saat flutter run aktif, tekan 'r' untuk hot reload dan 'R' untuk hot restart.
- Jika device_id tidak diisi, script memakai device default USB.
EOF
}

cmd="${1:-}"
device_id="${2:-$DEFAULT_DEVICE_ID}"

cd "$PROJECT_ROOT"

case "$cmd" in
  run)
    "$FLUTTER_BIN" run -d "$device_id"
    ;;
  attach)
    "$FLUTTER_BIN" attach -d "$device_id"
    ;;
  logs)
    adb -s "$device_id" logcat | grep --line-buffered -Ei "flutter|FATAL EXCEPTION|E/flutter|Unhandled Exception"
    ;;
  doctor)
    "$FLUTTER_BIN" doctor -v
    ;;
  devices)
    "$FLUTTER_BIN" devices
    ;;
  *)
    usage
    exit 1
    ;;
esac
