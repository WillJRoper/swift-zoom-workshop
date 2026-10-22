#!/bin/bash -l
#SBATCH --job-name=workshop_swift
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G
#SBATCH --partition=cosma8-serial
#SBATCH --account=dp004
#SBATCH --time=02:00:00
#SBATCH --output=swift-%j.out
#SBATCH --error=swift-%j.err

set -euo pipefail

module purge
module load intel_comp/2024.2.0 compiler-rt tbb compiler mpi
module load ucx/1.17.0 parallel_hdf5/1.14.4 fftw/3.3.10 gsl/2.8

ROOT=${WORKSHOP_ROOT:-${SLURM_SUBMIT_DIR:?Submit from the repository root or set WORKSHOP_ROOT}}
MODE=${MODE:-run}
STEPS=${STEPS:-16}
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"

[[ -x "$ROOT/scripts/run_swift.sh" ]] || { echo "Workshop not found at $ROOT" >&2; exit 1; }

OVERRIDES=(
  "ZoomRegion:zoom_min_top_level_cells:${ZOOM_MIN_CELLS:-8}"
  "ZoomRegion:bkg_top_level_cells:${BACKGROUND_CELLS:-33}"
  "Gravity:mesh_side_length:${MESH_SIDE_LENGTH:-128}"
)

case "$MODE" in
  geometry)
    "$ROOT/scripts/run_swift.sh" geometry "$SLURM_CPUS_PER_TASK" "${OVERRIDES[@]}"
    ;;
  run)
    "$ROOT/scripts/run_swift.sh" run "$SLURM_CPUS_PER_TASK" "$STEPS" "${OVERRIDES[@]}"
    ;;
  *)
    echo "MODE must be geometry or run" >&2
    exit 2
    ;;
esac
