#!/usr/bin/env bash
set -euo pipefail

ANDROID_SDK_ROOT="$HOME/Android/Sdk"
ANDROID_CMDLINE_URL="https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip"
ANDROID_CMDLINE_SHA256="4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583"

sudo apt-get update -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
cmdline_dir="$ANDROID_SDK_ROOT/cmdline-tools/latest"
if [[ ! -x "$cmdline_dir/bin/sdkmanager" ]]; then
  tmp_cmdline="$(mktemp /tmp/android-cmdline.XXXXXX.zip)"
  curl --fail --location --retry 3 --progress-bar "$ANDROID_CMDLINE_URL" --output "$tmp_cmdline"
  echo "$ANDROID_CMDLINE_SHA256  $tmp_cmdline" | sha256sum --check --status
  tmp_extract="$(mktemp -d /tmp/android-cmdline-extract.XXXXXX)"
  unzip -q "$tmp_cmdline" -d "$tmp_extract"
  rm -rf "$cmdline_dir"
  mv "$tmp_extract/cmdline-tools" "$cmdline_dir"
  rm -rf "$tmp_extract" "$tmp_cmdline"
fi

host_arch="$(uname -m)"
case "$host_arch" in
  x86_64|amd64)
    ;;
  aarch64|arm64)
    echo "Android command-line tools are installed, but Flutter's current official Linux stable archive is not executable on this ARM64 host."
    echo "The downloaded stable Dart binary was ELF x86-64 and failed with Exec format error. No Flutter project was generated."
    echo "Run this script on a compatible Linux x86_64 development host to install and validate the official Flutter stable SDK."
    exit 2
    ;;
  *)
    echo "Unsupported host architecture for the official Flutter Linux stable bundle: $host_arch" >&2
    exit 2
    ;;
esac

FLUTTER_HOME="$HOME/develop/flutter"
FLUTTER_RELEASES_JSON="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
release_info="$(python3 - "$FLUTTER_RELEASES_JSON" <<'PY'
import json, sys, urllib.request
with urllib.request.urlopen(sys.argv[1], timeout=60) as response:
    data = json.load(response)
stable_hash = data['current_release']['stable']
release = next(item for item in data['releases'] if item['hash'] == stable_hash)
print(release['archive'])
print(release['sha256'])
print(release['version'])
PY
)"
FLUTTER_ARCHIVE="$(printf '%s\n' "$release_info" | sed -n '1p')"
FLUTTER_SHA256="$(printf '%s\n' "$release_info" | sed -n '2p')"
FLUTTER_VERSION="$(printf '%s\n' "$release_info" | sed -n '3p')"

if [[ ! -x "$FLUTTER_HOME/bin/flutter" ]]; then
  mkdir -p "$HOME/develop"
  tmp_flutter="$(mktemp /tmp/flutter-sdk.XXXXXX.tar.xz)"
  curl --fail --location --retry 3 --progress-bar \
    "https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_ARCHIVE" \
    --output "$tmp_flutter"
  echo "$FLUTTER_SHA256  $tmp_flutter" | sha256sum --check --status
  tar -xf "$tmp_flutter" -C "$HOME/develop"
  rm -f "$tmp_flutter"
fi

mkdir -p "$HOME/develop"
block_start="# TeleManager Android toolchain"
if ! grep -Fq "$block_start" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<'EOF'

# TeleManager Android toolchain
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$HOME/develop/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
EOF
fi

export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
flutter --version
printf '\nFlutter stable selected: %s\n' "$FLUTTER_VERSION"
printf 'Android SDK command-line tools: %s\n' "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
printf 'Android SDK licenses have NOT been accepted.\n'
