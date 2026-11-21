#!/bin/sh
# Install a font family from the latest GitHub release of a repository.
# Usage: install-font.sh <owner/repo> <asset.zip> <dir-name>
# Idempotent: skips when the installed version matches the latest release.
set -eu

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <owner/repo> <asset.zip> <dir-name>" >&2
  exit 2
fi
REPO=$1
ASSET=$2
NAME=$3

case "$(uname -s)" in
  Darwin) FONT_DIR="$HOME/Library/Fonts/$NAME" ;;
  *)      FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/$NAME" ;;
esac
STAMP="$FONT_DIR/.version"

# Resolve the latest tag from the redirect, which avoids the rate-limited API.
latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
  "https://github.com/$REPO/releases/latest" | sed 's#.*/tag/##')
if [ -z "$latest" ]; then
  echo "install-font: could not resolve the latest release of $REPO" >&2
  exit 1
fi

if [ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$latest" ]; then
  echo "$NAME $latest already installed"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Downloading $NAME $latest"
curl -fsSL -o "$tmp/font.zip" \
  "https://github.com/$REPO/releases/download/$latest/$ASSET"
mkdir "$tmp/extract"
unzip -q "$tmp/font.zip" -d "$tmp/extract"

count=$(find "$tmp/extract" -type f -name '*.ttf' | wc -l | tr -d ' ')
if [ "$count" -eq 0 ]; then
  echo "install-font: no .ttf files in $ASSET" >&2
  exit 1
fi

mkdir -p "$FONT_DIR"
rm -f "$FONT_DIR"/*.ttf
find "$tmp/extract" -type f -name '*.ttf' -exec cp {} "$FONT_DIR/" \;
echo "$latest" > "$STAMP"

if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f "$FONT_DIR"
fi
echo "Installed $count font files to $FONT_DIR"
