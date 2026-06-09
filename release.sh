#!/usr/bin/env bash
set -euo pipefail

# Build a release of identify: a self-contained zip with prebuilt
# backend.wasm.gz, backend.did, frontend assets, and the icp.yaml
# project config so the recipient can deploy with `icp deploy -e mainnet`.

# This script is for maintainers. End users download the released
# zip and follow docs/self-deploy.md.

# Requirements (one of these build backends):
#   - icp-cli 0.3+ and moc 1.8.x (recommended; see recipe in icp.yaml)
#   - dfx 0.28+ and moc 0.16.x (legacy fallback for the current source
#     tree, which still uses `import IC "ic:aaaaa-aa"` URLs that
#     moc 1.8.x rejects without --actor-idl)

CLEAN=${CLEAN:-1}
BACKEND_WASM=${BACKEND_WASM:-backend.wasm.gz}
BACKEND_DID=${BACKEND_DID:-backend.did}
BUILD_BACKEND=${BUILD_BACKEND:-1}
BUILD_FRONTEND=${BUILD_FRONTEND:-1}

# Clean release folder
rm -rf release
mkdir release

# --- Backend ---
if [[ "$BUILD_BACKEND" == "1" ]]; then
  echo "Building backend..."
  if command -v icp >/dev/null 2>&1; then
    icp build backend
    WASM_SRC=".icp/cache/canisters/backend/backend.wasm.gz"
    DID_SRC=".icp/cache/canisters/backend/backend.did"
  elif command -v dfx >/dev/null 2>&1; then
    dfx build backend --network ic
    WASM_SRC=".dfx/ic/canisters/backend/backend.wasm"
    DID_SRC=".dfx/ic/canisters/backend/backend.did"
  else
    echo "Error: neither icp nor dfx found on PATH" >&2
    exit 1
  fi

  if [[ ! -f "$WASM_SRC" ]]; then
    echo "Error: expected build output at $WASM_SRC" >&2
    exit 1
  fi
  if [[ "$WASM_SRC" == *.gz ]]; then
    cp "$WASM_SRC" "release/$BACKEND_WASM"
  else
    # dfx output is uncompressed; compress to match what icp-cli produces
    gzip -c "$WASM_SRC" > "release/$BACKEND_WASM"
  fi
  cp "$DID_SRC" "release/$BACKEND_DID"
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
# Ship icp.yaml (the new tool's config) plus the legacy dfx.json
# (renamed, so dfx users can still deploy the prebuilt wasm).
echo "Copying icp.yaml..."
cp icp.yaml release/icp.yaml
echo "Copying dfx.json..."
cp release.dfx.json release/dfx.json

# --- Zip ---
echo "Creating release zip..."
(cd release && zip -r identify.zip . >/dev/null)

echo ""
echo "Release artifacts in ./release/:"
ls -l release
echo ""
echo "Release zip: release/identify.zip"
