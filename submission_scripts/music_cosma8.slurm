#!/bin/bash -l
#SBATCH --job-name=workshop_music
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=cosma8-serial
#SBATCH --account=dp004
#SBATCH --time=01:00:00
#SBATCH --output=music-%j.out
#SBATCH --error=music-%j.err

set -euo pipefail

module purge
module load intel_comp/2024.2.0 compiler-rt tbb compiler mpi
module load ucx/1.17.0 parallel_hdf5/1.14.4 fftw/3.3.10 gsl/2.8

ROOT=${WORKSHOP_ROOT:-${SLURM_SUBMIT_DIR:?Submit from the repository root or set WORKSHOP_ROOT}}
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"

[[ -x "$ROOT/scripts/run_music.sh" ]] || { echo "Workshop not found at $ROOT" >&2; exit 1; }
"$ROOT/scripts/run_music.sh"
