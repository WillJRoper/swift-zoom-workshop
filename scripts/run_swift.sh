#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage:" >&2
  echo "  $0 geometry THREADS [SECTION:KEY:VALUE ...]" >&2
  echo "  $0 run THREADS STEPS [SECTION:KEY:VALUE ...]" >&2
  exit 2
}

[[ $# -ge 2 ]] || usage
MODE=$1
THREADS=$2
shift 2

case "$MODE" in
  geometry) STEPS=0 ;;
  run)
    [[ $# -ge 1 ]] || usage
    STEPS=$1
    shift
    ;;
  *) usage ;;
esac

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SWIFT_DIR=${SWIFT_DIR:-"$ROOT/dependencies/SWIFT"}
SWIFT_BIN=${SWIFT_BIN:-"$SWIFT_DIR/swift"}
IC_FILE=${IC_FILE:-"$ROOT/data/zoom_ics.hdf5"}
RUN_DIR=${RUN_DIR:-"$ROOT/runs/zoom"}

[[ -x "$SWIFT_BIN" ]] || { echo "Missing SWIFT binary: $SWIFT_BIN" >&2; exit 1; }
[[ -f "$IC_FILE" ]] || { echo "Missing IC file: $IC_FILE" >&2; exit 1; }
mkdir -p "$RUN_DIR"
cp "$ROOT/configs/swift_dmo.yml" "$RUN_DIR/params.yml"
ln -sfn "$IC_FILE" "$RUN_DIR/ics.hdf5"

OVERRIDES=()
for value in "$@"; do
  OVERRIDES+=("--param=$value")
done
printf '%s\n' "$@" > "$RUN_DIR/overrides.txt"

COMMON=(--cosmology --self-gravity --zoom --threads="$THREADS" --timers=1 -v 1)

if [[ "$MODE" == geometry ]]; then
  (
    cd "$RUN_DIR"
    "$SWIFT_BIN" --cosmology --self-gravity --dump-zoom-geometry \
      --threads="$THREADS" "${OVERRIDES[@]}" params.yml 2>&1 | tee geometry.log
    python3 "$SWIFT_DIR/tools/zooms/plot_zoom_geometry.py" \
      --metadata zoom_metadata.yml --cells zoom_cell_data.dat --outdir geometry_plots
  )
  exit 0
fi

START=$(date +%s)
(
  cd "$RUN_DIR"
  rm -f snapshot_*.hdf5 output.log
  "$SWIFT_BIN" "${COMMON[@]}" --steps="$STEPS" \
    "${OVERRIDES[@]}" params.yml 2>&1 | tee output.log
)
END=$(date +%s)
echo "Run finished in $((END - START)) seconds; output is in $RUN_DIR"
