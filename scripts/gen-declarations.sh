#!/usr/bin/env bash
#
# Generate the frontend candid declarations (src/declarations/backend/) without
# dfx. Replaces `dfx generate`:
#
#   moc --idl            -> backend.did   (candid interface from the Motoko actor)
#   didc bind -t js      -> backend.did.js  (idlFactory)
#   didc bind -t ts      -> backend.did.d.ts (TypeScript types)
#   index.js / index.d.ts are committed wrappers (createActor/canisterId/backend).
#
# moc comes from mops (`mops toolchain bin moc`); didc is the official dfinity
# binary, pinned and cached under ~/.cache/didc. Run this after changing the
# backend's public interface, then commit the regenerated files.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

DIDC_VERSION="2025-12-18"
DIDC_DIR="${HOME}/.cache/didc/${DIDC_VERSION}"
DIDC="${DIDC_DIR}/didc"
OUT="src/declarations/backend"
MAIN="src/backend/main.mo"

# --- didc: download the pinned binary if not already cached ---
if [ ! -x "$DIDC" ]; then
  echo "didc ${DIDC_VERSION} not cached, downloading..."
  mkdir -p "$DIDC_DIR"
  curl -fsSL \
    "https://github.com/dfinity/candid/releases/download/${DIDC_VERSION}/didc-linux64" \
    -o "$DIDC"
  chmod +x "$DIDC"
fi

# --- moc: resolved through mops (same compiler icp build uses) ---
MOC="$(mops toolchain bin moc)"
PKGS="$(mops sources 2>/dev/null)"

mkdir -p "$OUT"

echo "moc --idl -> $OUT/backend.did"
# shellcheck disable=SC2086
"$MOC" $PKGS --idl "$MAIN" -o "$OUT/backend.did"

echo "didc bind -t js -> $OUT/backend.did.js"
"$DIDC" bind "$OUT/backend.did" -t js > "$OUT/backend.did.js"

echo "didc bind -t ts -> $OUT/backend.did.d.ts"
"$DIDC" bind "$OUT/backend.did" -t ts > "$OUT/backend.did.d.ts"

echo "declarations generated. index.js / index.d.ts are committed wrappers (not regenerated)."
