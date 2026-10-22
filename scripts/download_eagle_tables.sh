#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SWIFT_DIR=${SWIFT_DIR:-"$ROOT/dependencies/SWIFT"}
TABLE_DIR=${TABLE_DIR:-"$ROOT/runs/eagle"}
DOWNLOADS="$SWIFT_DIR/examples/EAGLE_ICs"

[[ -d "$DOWNLOADS" ]] || {
  echo "Missing SWIFT-EAGLE examples: $DOWNLOADS" >&2
  echo "Run scripts/build_swift_eagle.sh first." >&2
  exit 1
}

mkdir -p "$TABLE_DIR"
(
  cd "$TABLE_DIR"
  bash "$DOWNLOADS/getPS2020CoolingTables.sh"
  bash "$DOWNLOADS/getEagleYieldTable.sh"
  bash "$DOWNLOADS/getEaglePhotometryTable.sh"
)

echo "SWIFT-EAGLE tables downloaded to $TABLE_DIR"
