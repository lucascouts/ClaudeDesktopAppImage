#!/usr/bin/env bash
# Build a Claude Desktop AppImage from Anthropic's official .deb release.
# Usage: ./build.sh [x64|arm64] [path-to-local.deb]
set -euo pipefail

DEB_ARCH="${1:-x64}"
LOCAL_DEB="${2:-}"

case "$DEB_ARCH" in
	x64) APPIMAGE_ARCH="x86_64" ;;
	arm64) APPIMAGE_ARCH="aarch64" ;;
	*)
		echo "unsupported arch: $DEB_ARCH (use x64|arm64)" >&2
		exit 1
		;;
esac

for tool in curl jq ar tar; do
	command -v "$tool" >/dev/null || {
		echo "missing required tool: $tool" >&2
		exit 1
	}
done

UA="ClaudeDesktopAppImage (+https://github.com/lucascouts/ClaudeDesktopAppImage)"
API_URL="https://claude.ai/api/desktop/linux/${DEB_ARCH}/deb/latest"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# --- resolve latest version/url from Anthropic's API ---
META_JSON="$(curl -fsSL -A "$UA" "$API_URL")"
VERSION="$(jq -r .version <<<"$META_JSON")"
DEB_URL="$(jq -r .url <<<"$META_JSON")"
if ! [[ "$VERSION" =~ ^[0-9][0-9.]*$ ]]; then
	echo "unexpected version from API: $VERSION" >&2
	exit 1
fi
echo ">> latest ${DEB_ARCH}: ${VERSION}"

# --- obtain the .deb ---
DEB="$WORKDIR/claude.deb"
if [[ -n "$LOCAL_DEB" ]]; then
	cp "$LOCAL_DEB" "$DEB"
else
	curl -fL --retry 3 -A "$UA" -o "$DEB" "$DEB_URL"
fi

# --- unpack .deb into AppDir ---
APPDIR="$WORKDIR/AppDir"
mkdir -p "$APPDIR"
(cd "$WORKDIR" && ar x claude.deb && tar -xf data.tar.* -C AppDir)

# --- assemble AppDir ---
install -m755 "$HERE/AppRun" "$APPDIR/AppRun"
sed "s/@VERSION@/${VERSION}/" "$HERE/resources/claude-desktop.desktop" \
	>"$APPDIR/claude-desktop.desktop"
cp "$APPDIR/usr/share/icons/hicolor/256x256/apps/claude-desktop.png" "$APPDIR/claude-desktop.png"
cp "$APPDIR/claude-desktop.png" "$APPDIR/.DirIcon"
mkdir -p "$APPDIR/usr/share/metainfo"
sed "s/@VERSION@/${VERSION}/; s/@DATE@/$(date -u +%F)/" \
	"$HERE/resources/io.github.lucascouts.ClaudeDesktopAppImage.appdata.xml" \
	>"$APPDIR/usr/share/metainfo/io.github.lucascouts.ClaudeDesktopAppImage.appdata.xml"
# AppImages cannot ship setuid binaries; AppRun handles the sandbox fallback.
chmod 0755 "$APPDIR/usr/lib/claude-desktop/chrome-sandbox" || true

# --- appimagetool (host tool, builds any target arch via ARCH env) ---
# Pinned to a tagged release verified by sha256, not the mutable "continuous"
# channel, so a tampered or rotated upstream binary fails the build loudly.
APPIMAGETOOL_VERSION="1.9.1"
APPIMAGETOOL_SHA256="ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0"
TOOL="$HERE/appimagetool-${APPIMAGETOOL_VERSION}-x86_64.AppImage"
if [[ ! -x "$TOOL" ]]; then
	curl -fL --retry 3 -o "$TOOL" \
		"https://github.com/AppImage/appimagetool/releases/download/${APPIMAGETOOL_VERSION}/appimagetool-x86_64.AppImage"
	chmod +x "$TOOL"
fi
echo "${APPIMAGETOOL_SHA256}  ${TOOL}" | sha256sum -c - || {
	echo "appimagetool checksum mismatch -- refusing to build" >&2
	rm -f "$TOOL"
	exit 1
}

OUT="Claude_Desktop_Unofficial-${VERSION}-${APPIMAGE_ARCH}.AppImage"
UPDATE_INFO="gh-releases-zsync|lucascouts|ClaudeDesktopAppImage|latest|Claude_Desktop_Unofficial-*-${APPIMAGE_ARCH}.AppImage.zsync"
ARCH="$APPIMAGE_ARCH" "$TOOL" --appimage-extract-and-run \
	-u "$UPDATE_INFO" "$APPDIR" "$OUT"

echo ">> built: $OUT"
