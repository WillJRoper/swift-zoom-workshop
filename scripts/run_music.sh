#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MUSIC_DIR=${MUSIC_DIR:-"$ROOT/dependencies/MUSIC2"}
MUSIC_BIN=${MUSIC_BIN:-"$MUSIC_DIR/build/MUSIC"}
WORK_DIR=${WORK_DIR:-"$ROOT/runs/music"}

[[ -x "$MUSIC_BIN" ]] || { echo "Missing MUSIC binary: $MUSIC_BIN" >&2; exit 1; }
mkdir -p "$WORK_DIR"
cp "$ROOT/configs/music.conf" "$WORK_DIR/music.conf"
cp "$ROOT/data/tessera_P00000_R0000_region_points.txt" "$WORK_DIR/"
cp "$ROOT/data/tessera_P00000_camb_transfer.dat" "$WORK_DIR/"

(
  cd "$WORK_DIR"
  "$MUSIC_BIN" music.conf 2>&1 | tee music.log
)

cp "$WORK_DIR/zoom_ics.hdf5" "$ROOT/data/zoom_ics.hdf5"
echo "IC written to $ROOT/data/zoom_ics.hdf5"
