#!/bin/sh
# zol install / update.
#
# Fetches a release tarball from the public zol-releases repo, verifies its
# SHA-256, installs the binary under ~/.local/bin and the grammar packs under
# ~/.local/lib/zol, then registers a desktop entry. Re-running upgrades in
# place. See docs/releases.md §8.
#
#   curl -fsSL https://github.com/flyewic/zol-releases/releases/latest/download/install.sh | sh
#
# Environment:
#   ZOL_VERSION             install this exact version, e.g. 0.1.1 (default: latest)
#   ZOL_RELEASES_REPO       override the release repo (default flyewic/zol-releases)
#   ZOL_UPDATE_EXPLANATION  message to show instead of installing when a
#                           package-managed zol is found (for packagers)

set -eu

REPO="${ZOL_RELEASES_REPO:-flyewic/zol-releases}"
PREFIX="${HOME}/.local/bin"
LIBDIR="${HOME}/.local/lib/zol"

die() {
    printf 'zol install: %s\n' "$*" >&2
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

need curl
need tar
if command -v sha256sum >/dev/null 2>&1; then
    sha_hex() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
    sha_hex() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
    die "need sha256sum or shasum"
fi

arch="$(uname -m)"
case "$arch" in
    x86_64 | amd64) ;;
    *) die "no binary for this architecture (${arch}); only x86_64 is supported" ;;
esac

# Refuse to overwrite a binary the user did not install with this script.
if command -v zol >/dev/null 2>&1; then
    existing="$(command -v zol)"
    case "$existing" in
        "${HOME}/.local/bin/"*) ;;
        *)
            if [ -n "${ZOL_UPDATE_EXPLANATION:-}" ]; then
                printf '%s\n' "$ZOL_UPDATE_EXPLANATION" >&2
                exit 0
            fi
            die "found ${existing}, which is not managed by this installer; update it with your package manager"
            ;;
    esac
fi

# Resolve the version: explicit, else the latest release's tag.
if [ -n "${ZOL_VERSION:-}" ]; then
    version="${ZOL_VERSION#v}"
else
    tag="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
        | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        | head -n 1)"
    [ -n "$tag" ] || die "could not resolve the latest release from ${REPO}"
    version="${tag#v}"
fi

name="zol-${version}-linux-x86_64"
tarball="${name}.tar.gz"
base="https://github.com/${REPO}/releases/download/v${version}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/$tarball" "$base/$tarball"
curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS"

expected="$(sed -n "s/^\([0-9a-fA-F]\{64\}\)[[:space:]][[:space:]]*${tarball}\$/\1/p" "$tmp/SHA256SUMS" | head -n 1)"
[ -n "$expected" ] || die "checksum for ${tarball} not found in SHA256SUMS"
actual="$(sha_hex "$tmp/$tarball")"
[ "$actual" = "$expected" ] || die "checksum mismatch for ${tarball}"

mkdir -p "$tmp/x"
tar -xzf "$tmp/$tarball" -C "$tmp/x"
src="$tmp/x/$name"
[ -x "$src/zol" ] || die "archive did not contain a zol binary"

mkdir -p "$PREFIX"
install -m755 "$src/zol" "$PREFIX/zol.new"
mv -f "$PREFIX/zol.new" "$PREFIX/zol"

if [ -d "$src/languages" ]; then
    rm -rf "${LIBDIR}/languages"
    mkdir -p "$LIBDIR"
    cp -a "$src/languages" "$LIBDIR/languages"
fi

"$PREFIX/zol" --install-desktop || printf 'zol install: warning: --install-desktop failed\n' >&2

"$PREFIX/zol" --version

case ":${PATH}:" in
    *":${PREFIX}:"*) ;;
    *) printf 'zol install: add %s to your PATH to run zol\n' "$PREFIX" >&2 ;;
esac
