#!/usr/bin/env bash
set -euo pipefail

# Build a release of identify: a self-contained zip with prebuilt
# backend.wasm.gz, backend.did, frontend assets, and the icp.yaml
# project config so the recipient can deploy with the `icp` CLI.
#
# This script is for maintainers. End users download the released
# zip and follow docs/self-deploy.md.
#
# Requirements: icp-cli 0.3+, moc 1.8.x (via mops), ic-wasm, and node.
# (The backend candid is read out of the built wasm's candid:service
# metadata with ic-wasm, so it always matches the shipped wasm.)

BACKEND_WASM=${BACKEND_WASM:-backend.wasm.gz}
BACKEND_DID=${BACKEND_DID:-backend.did}
BUILD_BACKEND=${BUILD_BACKEND:-1}
BUILD_FRONTEND=${BUILD_FRONTEND:-1}

command -v icp >/dev/null 2>&1 || {
  echo "Error: icp CLI not found on PATH (see docs/self-deploy.md)" >&2
  exit 1
}

# Clean release folder
rm -rf release
mkdir release

# --- Backend ---
if [[ "$BUILD_BACKEND" == "1" ]]; then
  echo "Building backend..."
  icp build backend
  WASM_SRC=".icp/cache/artifacts/backend"

  if [[ ! -f "$WASM_SRC" ]]; then
    echo "Error: expected build output at $WASM_SRC" >&2
    exit 1
  fi

  echo "Compressing wasm -> release/$BACKEND_WASM"
  gzip -c "$WASM_SRC" > "release/$BACKEND_WASM"

  command -v ic-wasm >/dev/null 2>&1 || {
    echo "Error: ic-wasm not found (npm i -g @icp-sdk/ic-wasm)" >&2
    exit 1
  }
  echo "Extracting candid -> release/$BACKEND_DID"
  ic-wasm "$WASM_SRC" metadata candid:service > "release/$BACKEND_DID"
fi

# --- Frontend ---
if [[ "$BUILD_FRONTEND" == "1" ]]; then
  echo "Building frontend..."
  if [[ ! -d out/frontend ]]; then
    npm run build
  fi
  cp -r out/frontend release/
fi

# --- Project config ---
echo "Copying icp.yaml..."
cp icp.yaml release/icp.yaml

# --- Zip ---
echo "Creating release zip..."
(cd release && zip -r identify.zip . >/dev/null)

echo ""
echo "Release artifacts in ./release/:"
ls -l release
echo ""
echo "Release zip: release/identify.zip"
